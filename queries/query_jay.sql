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
-- Select the best k items for a hero(build of a hero)
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
select round(100*(numerator.count/cast(denominator.count as decimal) ),2)as radiant_wins from
(
    select count(1) from match
) denominator,
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
