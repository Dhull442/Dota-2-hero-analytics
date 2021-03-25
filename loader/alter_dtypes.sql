CREATE OR REPLACE FUNCTION changedtypes(
    IN _tname TEXT,     -- tablename to alter
    VARIADIC _cname TEXT[]  -- all columnnames to alter
) 
RETURNS boolean 
LANGUAGE plpgsql 
AS
$$
DECLARE
    row record;
BEGIN   
    FOR row IN SELECT unnest(_cname) AS colname LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(_tname) || ' ALTER COLUMN ' || quote_ident(row.colname) || ' type numeric using ' || quote_ident(row.colname) || '::numeric';
    END LOOP;

    RETURN TRUE;
END;
$$;

create table teamfights(
    "match_id" numeric,
    "start" numeric,
    "end" numeric,
    "last_death" numeric,
    "deaths" numeric
);

copy teamfights from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/teamfights.csv' delimiter ',' CSV HEADER;
;

copy players from '/media/jay/7E5662245661DE01/sem8/DBMS/project/archive/players.csv' delimiter ',' CSV HEADER;
;

SELECT changedtypes('ability_ids','ability_id')
;
SELECT changedtypes('ability_upgrades','ability','level','time','player_slot','match_id')
;
SELECT changedtypes('cluster_regions','cluster')
;
SELECT changedtypes('hero_names','hero_id')
;
SELECT changedtypes('item_ids','item_id')
;
SELECT changedtypes('match','match_id','start_time','duration','tower_status_radiant',
       'tower_status_dire', 'barracks_status_dire', 'barracks_status_radiant',
       'first_blood_time', 'game_mode', 'negative_votes',
       'positive_votes', 'cluster')
;
SELECT changedtypes('match_outcomes','match_id', 'account_id_0', 'account_id_1', 'account_id_2',
       'account_id_3', 'account_id_4', 'start_time', 'parser_version', 'win',
       'rad')
;
SELECT changedtypes('objectives','match_id', 
	--'key',
	 'player1', 'player2', 
	 --'slot', 'team',
       'time', 'value')
;
SELECT changedtypes('patch_dates', 'name')
;
SELECT changedtypes('player_ratings','account_id', 'total_wins', 'total_matches', 'trueskill_mu',
       'trueskill_sigma')
;
SELECT changedtypes('players','match_id', 'account_id', 'hero_id', 'player_slot', 'gold',
       'gold_spent', 'gold_per_min', 'xp_per_min', 'kills', 'deaths',
       'assists', 'denies', 'last_hits', 'hero_damage',
       'hero_healing', 'tower_damage', 'item_0', 'item_1', 'item_2', 'item_3',
       'item_4', 'item_5', 'level', 'leaver_status', 'xp_hero', 'xp_creep',
       'xp_roshan', 'xp_other', 'gold_other', 'gold_death', 'gold_buyback',
       'gold_abandon', 'gold_sell', 'gold_destroying_structure',
       'gold_killing_heros', 'gold_killing_creeps', 'gold_killing_roshan',
       'gold_killing_couriers',
       'unit_order_move_to_position', 'unit_order_move_to_target',
       'unit_order_attack_move', 'unit_order_attack_target',
       'unit_order_cast_position', 'unit_order_cast_target',
       'unit_order_cast_target_tree', 'unit_order_cast_no_target',
       'unit_order_cast_toggle', 'unit_order_hold_position',
       'unit_order_train_ability', 'unit_order_drop_item',
       'unit_order_give_item', 'unit_order_pickup_item',
       'unit_order_pickup_rune', 'unit_order_purchase_item',
       'unit_order_sell_item', 'unit_order_disassemble_item',
       'unit_order_move_item', 'unit_order_cast_toggle_auto',
       'unit_order_stop', 'unit_order_buyback',
       'unit_order_glyph', 'unit_order_eject_item_from_stash',
       'unit_order_ping_ability',
       'unit_order_move_to_direction')
;
SELECT changedtypes('player_time','match_id', 'times', 'gold_t_0', 'lh_t_0', 'xp_t_0', 'gold_t_1',
       'lh_t_1', 'xp_t_1', 'gold_t_2', 'lh_t_2', 'xp_t_2', 'gold_t_3',
       'lh_t_3', 'xp_t_3', 'gold_t_4', 'lh_t_4', 'xp_t_4', 'gold_t_128',
       'lh_t_128', 'xp_t_128', 'gold_t_129', 'lh_t_129', 'xp_t_129',
       'gold_t_130', 'lh_t_130', 'xp_t_130', 'gold_t_131', 'lh_t_131',
       'xp_t_131', 'gold_t_132', 'lh_t_132', 'xp_t_132')
;
SELECT changedtypes('purchase_log','item_id', 'time', 'player_slot', 'match_id')
;
SELECT changedtypes('teamfights','match_id', 'start', 'end', 'last_death', 'deaths')
;
SELECT changedtypes('teamfights_players','match_id', 'player_slot', 'buybacks', 'damage', 'deaths', 'gold_delta',
       'xp_end', 'xp_start')
;
SELECT changedtypes('test_labels','match_id', 'radiant_win')
;
SELECT changedtypes('test_player','match_id', 'account_id', 'hero_id', 'player_slot')
;
