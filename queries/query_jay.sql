--Materialized Views
CREATE MATERIALIZED VIEW num_matches(num_matches)
as(
    select cast(count(1) as decimal) from match
);

CREATE MATERIALIZED VIEW player_hero_wins(match_id, hero_name, player_slot, won, gpm, xppm, damage, healing, tower_damage, K, D, A)
as(
    select players.match_id, hero_names.localized_name as hero_name, player_slot,
    ((radiant_win='True' AND player_slot<5) OR (radiant_win='False' AND player_slot>100)) as won,
    gold_per_min, xp_per_min, hero_damage, hero_healing, tower_damage,
    round(avg(kills), 2) as average_kills, round(avg(deaths), 2) as average_deaths, round(avg(assists), 2) as average_assists
    from players, match, hero_names
    where(
        match.match_id = players.match_id and
        players.hero_id = hero_names.hero_id
    )
    group by players.match_id, hero_names.localized_name, player_slot,won, gold_per_min, xp_per_min, hero_damage, hero_healing, tower_damage
);

CREATE MATERIALIZED VIEW hero_builds(hero_name, item0, item1, item2, item3, item4, item5,
build_count, win_rate, rn)
as(
    select localized_name, item0.item_name, item1.item_name, item2.item_name,
    item3.item_name, item4.item_name, item5.item_name, count, wr,
    row_number() over(partition by localized_name
    order by count DESC, wr DESC, item0.item_name, item1.item_name, item2.item_name, item3.item_name, item4.item_name, item5.item_name) rn
    from
    (
        select localized_name, item_0, item_1, item_2,item_3, item_4, item_5,
        count(1),
        sum(((radiant_win='True' AND player_slot<5) OR (radiant_win='False' AND player_slot>100))::int) as wr
        from hero_names, players, match
        where(
            hero_names.hero_id = players.hero_id AND
            match.match_id = players.match_id
        )
        group by localized_name, item_0, item_1, item_2, item_3, item_4, item_5
    ) dummy
    inner join item_ids as item0 on(dummy.item_0=item0.item_id)
    inner join item_ids as item1 on(dummy.item_1=item1.item_id)
    inner join item_ids as item2 on(dummy.item_2=item2.item_id)
    inner join item_ids as item3 on(dummy.item_3=item3.item_id)
    inner join item_ids as item4 on(dummy.item_4=item4.item_id)
    inner join item_ids as item5 on(dummy.item_5=item5.item_id)
)
;
--Views


-- 1 --
-- Select the top k most selected heroes
select min as hero_name from
(
    select min(localized_name), count(1) from
    players inner join hero_names using(hero_id)
    group by hero_id
    order by count desc
    limit 10
) foo
;

--2--
-- Select the best k items for a hero
select hero_name, item_name, rn from
(
    select min(item_name) as item_name, count(distinct item_id),
    min(localized_name) as hero_name,
    row_number() over(partition by hero_id order by count(distinct item_id) DESC, min(item_name)) rn
    from
    purchase_log
    inner join (
        select match_id, hero_id, player_slot
        from players
    ) players_imp using(match_id, player_slot)
    inner join hero_names using(hero_id)
    inner join item_ids using(item_id)
    group by hero_id, item_id
) foo
where(
    foo.rn<7 --k
    and hero_name='Windranger'
)
order by hero_name, item_name
;
--3--
--Get the percentage of radiant wins
select round(100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from
-- select round(100*(numerator.count/cast(denominator.count as decimal) ),2)as radiant_wins from
num_matches,
(
    select count(1) from match
    where radiant_win = 'True'
) numerator
;
--4--
--Get stats of hero vs hero win rate
with hero1(p1_id) as
(
    select hero_id from hero_names
    where localized_name='Axe'
    limit 1
),
hero2(p2_id) as
(
    select hero_id from hero_names
    where localized_name='Bane'
    limit 1
),
foo1(match_id, hero_id, player_slot, radiant_win) as
(
    select match.match_id, hero_id, players.player_slot, radiant_win
    from players, match, hero1
    where (hero_id = hero1.p1_id and match.match_id = players.match_id)
),
foo2(match_id, hero_id, player_slot, radiant_win) as
(
    select match.match_id, hero_id, players.player_slot, radiant_win
    from players, match, hero2
    where (hero_id = hero2.p2_id and match.match_id = players.match_id)
)

select round(100*(h1.p1_wins/cast(h2.total_p1p2 as decimal)),2) as p1p2_winrate from
(
    select count(distinct foo1.match_id) as p1_wins from
    foo1,foo2
    where
    (
        foo1.match_id = foo2.match_id and
        (
            (foo1.player_slot < 5 and foo2.player_slot>100 and foo1.radiant_win='True')
            or
            (foo1.player_slot > 100 and foo2.player_slot<5 and foo1.radiant_win='False')
        )
    )
) h1,
(
    select count(distinct foo1.match_id) as total_p1p2 from
    foo1,foo2
    where
    (
        foo1.match_id = foo2.match_id and
        (
            (foo1.player_slot < 5 and foo2.player_slot>100)
            or
            (foo1.player_slot > 100 and foo2.player_slot<5)
        )
    )
) h2
;

--5--
-- pick rate of heroes, win rate, number of matches played
select hero_name, count(1) as num_matches_played, round(100*(count(1)/min(num_matches)),2) as pick_rate,
round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,
avg(gpm) as gold_per_minute, avg(xppm) as xp_per_minute, avg(damage) as damage,
avg(healing) as healing, avg(tower_damage) as tower_damage
from player_hero_wins, num_matches
group by hero_name
order by pick_rate desc, win_rate desc, hero_name
-- limit 10
;

--6--
--full build of heroes
select * from hero_builds
where rn<4;
