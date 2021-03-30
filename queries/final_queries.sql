-- --Index
-- create index player_indx on players(hero_id);
-- create index hero_names_indx on hero_names(hero_id);
-- create index purchase_indx on purchase_log(match_id)
-- ;
-- create index match_indx on match(match_id)
-- ;
-- create index player_indx_2 on players(match_id, player_slot)
-- ;

-- create index ability_upgarde_indx_2 on ability_upgrades(match_id, player_slot)
-- ;

-- create index ability_indx_2 on ability_ids(ability_id)
-- ;


-- --Materialized Views in the Database
-- CREATE MATERIALIZED VIEW num_matches(num_matches)
-- as(
--     select cast(count(1) as decimal) from match
-- );

-- CREATE MATERIALIZED VIEW player_hero_wins(match_id, hero_name, player_slot, won, gpm, xppm, damage, healing, tower_damage, K, D, A)
-- as(
--     select players.match_id, hero_names.localized_name as hero_name, player_slot, 
--     ((radiant_win='True' AND player_slot<5) OR (radiant_win='False' AND player_slot>100)), 
--     gold_per_min, xp_per_min, hero_damage, hero_healing, tower_damage,
--     kills,deaths, assists
--     from players, match, hero_names
--     where(
--         match.match_id = players.match_id and
--         players.hero_id = hero_names.hero_id
--     )
-- );

-- CREATE MATERIALIZED VIEW hero_builds(hero_name, item0, item1, item2, item3, item4, item5,
-- build_count, win_rate, rn)
-- as(
--     select localized_name, item0.item_name, item1.item_name, item2.item_name, 
--     item3.item_name, item4.item_name, item5.item_name, count, wr,
--     row_number() over(partition by localized_name
--     order by count DESC, wr DESC, item0.item_name, item1.item_name, item2.item_name, item3.item_name, item4.item_name, item5.item_name) rn
--     from
--     (
--         select localized_name, item_0, item_1, item_2,item_3, item_4, item_5,
--         count(1), 
--         sum(((radiant_win='True' AND player_slot<5) OR (radiant_win='False' AND player_slot>100))::int) as wr
--         from hero_names, players, match
--         where(
--             hero_names.hero_id = players.hero_id AND
--             match.match_id = players.match_id
--         )
--         group by localized_name, item_0, item_1, item_2, item_3, item_4, item_5
--     ) dummy
--     inner join item_ids as item0 on(dummy.item_0=item0.item_id)
--     inner join item_ids as item1 on(dummy.item_1=item1.item_id)
--     inner join item_ids as item2 on(dummy.item_2=item2.item_id)
--     inner join item_ids as item3 on(dummy.item_3=item3.item_id)
--     inner join item_ids as item4 on(dummy.item_4=item4.item_id)
--     inner join item_ids as item5 on(dummy.item_5=item5.item_id)
-- )
-- ;

-- create materialized view player_hero(account_id, hero_id, localized_name, gold, denies, 
-- xp_hero, xp_creep, stuns) as (
--     select account_id, hero_names.hero_id, localized_name, gold as gold_left, denies,
--     xp_hero, xp_creep, 
--     (
--         case 
--         when stuns = 'None' then 0
--         else cast(stuns as float)
--         end
--     ) as stuns
--     from players
--     inner join hero_names on hero_names.hero_id = players.hero_id
-- );

-- create materialized view match_cluster(match_id, region) as (
--     select match_id, region 
--     from match
--     inner join cluster_regions on match.cluster = cluster_regions.cluster
-- )
-- ;

-- create materialized view win_rate(item_name, win_rate) as (
--     select item_ids.item_name, round(win_rate * 100, 2) as win_rate from 
--     (
--         select item_id, avg(
--             case when player_slot <= 3 and radiant_win = 'True' then 1
--             when player_slot > 3 and radiant_win = 'False' then 1
--             else 0
--             end
--         ) as win_rate from 
--         purchase_log
--         inner join match on match.match_id = purchase_log.match_id
--         group by item_id
--     ) temp
--     inner join item_ids on  item_ids.item_id = temp.item_id
--     order by win_rate desc
-- );

-- create materialized view early_game(item_name, times_purchased) as (
--     select item_ids.item_name, times_purchased from 
--     (
--         select item_id, count(*) as times_purchased, 
--         rank() over (order by count(*) desc) 
--         from purchase_log
--         where time < 0
--         group by item_id
--     ) as temp
--     inner join item_ids on temp.item_id = item_ids.item_id
--     order by rank
    
-- );

-- create materialized view mid_game(item_name, times_purchased) as (
--     select item_ids.item_name, times_purchased from 
--     (
--         select item_id, count(*) as times_purchased, 
--         rank() over (order by count(*) desc) 
--         from purchase_log
--         where time < 1500 and
--         time > 500
--         group by item_id
--     ) as temp
--     inner join item_ids on temp.item_id = item_ids.item_id
--     order by rank
    
-- );

-- create materialized view end_game(item_name, times_purchased) as (
--     select item_ids.item_name, times_purchased from 
--     (
--         select item_id, count(*) as times_purchased, 
--         rank() over (order by count(*) desc) 
--         from purchase_log
--         where time > 2000
--         group by item_id
--     ) as temp
--     inner join item_ids on temp.item_id = item_ids.item_id
--     order by rank
-- );

--Hero Queries

--Most Played--
select hero_name, count(1) as num_matches_played, round(100*(count(1)/min(num_matches)),2) as pick_rate, 
round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,
round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA
from player_hero_wins, num_matches
group by hero_name
order by pick_rate desc, win_rate desc, hero_name
;

--Win Rate--
select hero_name, 
round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,
round(100*(count(1)/min(num_matches)),2) as pick_rate,
round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA
from player_hero_wins, num_matches
group by hero_name
order by win_rate desc, pick_rate desc, hero_name
;

--GameImpact--
select hero_name, 
round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA,
round(avg(K),2) as K,
round(avg(D),2) as D,
round(avg(A),2) as A
from player_hero_wins, num_matches
group by hero_name
order by KDA desc, hero_name
;

--Economy--
select hero_name, round(avg(gpm),2) as "Gold / Minute", round(avg(xppm),2) as "Experience / Minute"
from player_hero_wins
group by hero_name
order by "Gold / Minute" desc, "Experience / Minute" desc,hero_name
;

--Damage And Healing--
select hero_name, round(avg(damage),2) as "Average Damage", round(avg(tower_damage),2) as "Average Tower Damage",
round(avg(healing),2) as "Average Healing"
from player_hero_wins
group by hero_name
order by "Average Damage" desc, "Average Tower Damage" desc, "Average Healing" desc, hero_name
;

--All Heroes--
select localized_name as name from hero_names
order by localized_name
;

--Hero Particular Queries
--Hero Vs Hero Win rate
with hero1(p1_id) as
(
    select hero_id from hero_names
    where localized_name='Axe'  --put hero 1 name here
    limit 1 
),
hero2(p2_id) as
(
    select hero_id from hero_names
    where localized_name='Bane'  --put hero 2 name here
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

--Top k Build Order--
select item0, item1, item2, item3, item4, item5,
build_count, round(100*win_rate/cast(build_count as decimal),2) as win_rate
from hero_builds
where rn<=3 and hero_name='Axe' --select k and name here
;

--Top k Ability Order
--TODO
-- Ability upgrade order
with hero1(p1_id) as
(
    select hero_id from hero_names
    where localized_name='Axe'  --put hero 1 name here
    limit 1 
),
hero_ability(match_id, slot, ability_name, time, hero_id) as (
    select players.match_id, players.player_slot, ability_name, time, players.hero_id
    from players
    inner join hero1 on hero1.p1_id=players.hero_id
    inner join ability_upgrades on 
    players.match_id = ability_upgrades.match_id and
    players.player_slot = ability_upgrades.player_slot
    inner join ability_ids on 
    ability_ids.ability_id = ability_upgrades.ability
)
select *, count(*) as count from (
    select hero_id, array_agg(ability_name order by time) as ability_order from
    hero_ability
    group by hero_id, slot, match_id
) temp
group by hero_id, ability_order
order by count desc
limit 3 --Choose k here
;


--General Queries
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

--Get the percentage of radiant wins
select round(100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from
-- select round(100*(numerator.count/cast(denominator.count as decimal) ),2)as radiant_wins from
num_matches,
(
    select count(1) from match
    where radiant_win = 'True'
) numerator
;

-- Most deadly teamfights
select deaths, region from
(
    select match_id, max(deaths) as deaths
    from teamfights
    group by match_id

) temp, match_cluster
where temp.match_id = match_cluster.match_id
order by deaths desc
limit 5
;


--Item Queries
-- Early, mid, late stage items
select * from early_game
order by times_purchased desc;

select * from mid_game
order by times_purchased desc;

select * from end_game
order by times_purchased desc;

-- Most win rate of items
select * from win_rate
order by win_rate desc
;


--Achievements

-- Filthy rich
select account_id, localized_name, gold as gold_left
from player_hero
where gold > 15000
order by gold desc
;

-- Not on my watch
select account_id, localized_name, denies
from player_hero
where denies > 40
order by denies desc
;

-- Hero Farmer
select account_id, localized_name, xp_hero
from player_hero
where xp_hero > 24000
order by xp_hero desc
;

-- Goblin slayer
select account_id, localized_name, xp_creep
from player_hero
where xp_creep > 26000
order by xp_creep desc
;

-- Controller of Crowds
select account_id, localized_name, stuns
from player_hero
where stuns > 300
order by stuns desc
;

-- Good Game
select match_id, positive_votes, region
from match_cluster
where positive_votes > 50
order by positive_votes desc
;

-- Blame Game
select match_id, negative_votes, region
from match_cluster
where negative_votes > 10
order by negative_votes desc
;