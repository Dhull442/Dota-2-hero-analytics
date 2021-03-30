create index player_indx on players(hero_id);
create index hero_names_indx on hero_names(hero_id);
create index purchase_indx on purchase_log(match_id)
;
create index match_indx on match(match_id)
;
create index player_indx_2 on players(match_id, player_slot)
;

create index ability_upgarde_indx_2 on ability_upgrades(match_id, player_slot)
;

create index ability_indx_2 on ability_ids(ability_id)
;

-- Hero KDA
select hero_names.localized_name as hero_name, round(avg(kills), 2) as average_kills, 
round(avg(deaths), 2) as average_deaths, round(avg(assists), 2) as average_assists
from players
inner join hero_names on players.hero_id = hero_names.hero_id
group by hero_names.localized_name
;

-- Early, mid, late stage items
select item_ids.item_name, times_purchased from 
(
    select item_id, count(*) as times_purchased, 
    rank() over (order by count(*) desc) 
    from purchase_log
    where time < 0 -- Can modify for different stages
    group by item_id
) as temp
inner join item_ids on temp.item_id = item_ids.item_id
order by rank
;



--! Takes 4 s
-- Most win rate of items
select item_ids.item_name, round(win_rate * 100, 2) as win_rate from 
(
    select item_id, avg(
        case when player_slot <= 3 and radiant_win = 'True' then 1
        when player_slot > 3 and radiant_win = 'False' then 1
        else 0
        end
    ) as win_rate from 
    purchase_log
    inner join match on match.match_id = purchase_log.match_id
    group by item_id
) temp
inner join item_ids on  item_ids.item_id = temp.item_id
order by win_rate desc
;

-- Ability upgrade order
with hero_ability(match_id, slot, ability_name, time, hero_id) as (
    select players.match_id, players.player_slot, ability_name, time, players.hero_id
    from ability_upgrades
    inner join players on 
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
;

-- Most deadly teamfights
select match_id, deaths from
(
    select match_id, deaths,
    rank() over (partition by match_id order by deaths desc, start)
    from teamfights

) temp
where rank = 1
;

create materialized view player_hero(account_id, hero_id, localized_name, gold, denies, 
xp_hero, xp_creep, stuns) as (
    select account_id, hero_names.hero_id, localized_name, gold as gold_left, denies,
    xp_hero, xp_creep, 
    (
        case 
        when stuns = 'None' then 0
        else cast(stuns as float)
        end
    ) as stuns
    from players
    inner join hero_names on hero_names.hero_id = players.hero_id
);

Achievements
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

-- Not on my watch
select account_id, localized_name, stuns
from player_hero
where stuns > 300
order by stuns desc
;

drop materialized view player_hero;