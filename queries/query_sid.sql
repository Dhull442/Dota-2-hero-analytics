create index player_indx on players(hero_id);
create index hero_names_indx on hero_names(hero_id);
create index purchase_indx on purchase_log(match_id)
;
create index match_indx on match(match_id)
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