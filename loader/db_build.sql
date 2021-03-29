CREATE TABLE ability_ids (
	ability_id DECIMAL, 
	ability_name VARCHAR
);
CREATE TABLE ability_upgrades (
	ability DECIMAL,
	level DECIMAL,
	time DECIMAL,
	player_slot DECIMAL,
	match_id DECIMAL
);

CREATE TABLE cluster_regions (
	cluster DECIMAL,
	region VARCHAR
);
CREATE TABLE hero_names (
	name VARCHAR,
	hero_id DECIMAL,
	localized_name VARCHAR
);
CREATE TABLE item_ids (
	item_id DECIMAL,
	item_name VARCHAR
);

CREATE TABLE match (
	match_id DECIMAL,
	start_time DECIMAL,
	duration DECIMAL,
	tower_status_radiant DECIMAL,
	tower_status_dire DECIMAL,
	barracks_status_dire DECIMAL,
	barracks_status_radiant DECIMAL,
	first_blood_time DECIMAL,
	game_mode DECIMAL,
	radiant_win BOOLEAN,
	negative_votes DECIMAL,
	positive_votes DECIMAL,
	cluster DECIMAL
);
CREATE TABLE match_outcomes (
	match_id DECIMAL,
	account_id_0 DECIMAL,
	account_id_1 DECIMAL,
	account_id_2 DECIMAL,
	account_id_3 DECIMAL,
	account_id_4 DECIMAL,
	start_time DECIMAL,
	parser_version DECIMAL,
	win DECIMAL,
	rad DECIMAL
);
CREATE TABLE objectives (
	match_id DECIMAL,
	key DECIMAL,
	player1 DECIMAL,
	player2 DECIMAL,
	slot DECIMAL,
	subtype VARCHAR,
	team DECIMAL,
	time DECIMAL,
	value DECIMAL
);
CREATE TABLE patch_dates (
	patch_date TIMESTAMP,
	name DECIMAL
);
CREATE TABLE player_ratings (
	account_id DECIMAL,
	total_wins DECIMAL,
	total_matches DECIMAL,
	trueskill_mu DECIMAL,
	trueskill_sigma DECIMAL
);

CREATE TABLE players (
	match_id DECIMAL,
	account_id DECIMAL,
	hero_id DECIMAL,
	player_slot DECIMAL,
	gold DECIMAL,
	gold_spent DECIMAL,
	gold_per_min DECIMAL,
	xp_per_min DECIMAL,
	kills DECIMAL,
	deaths DECIMAL,
	assists DECIMAL,
	denies DECIMAL,
	last_hits DECIMAL,
	stuns VARCHAR,
	hero_damage DECIMAL,
	hero_healing DECIMAL,
	tower_damage DECIMAL,
	item_0 DECIMAL,
	item_1 DECIMAL,
	item_2 DECIMAL,
	item_3 DECIMAL,
	item_4 DECIMAL,
	item_5 DECIMAL,
	level DECIMAL,
	leaver_status DECIMAL,
	xp_hero DECIMAL,
	xp_creep DECIMAL,
	xp_roshan DECIMAL,
	xp_other DECIMAL,
	gold_other DECIMAL,
	gold_death DECIMAL,
	gold_buyback DECIMAL,
	gold_abandon DECIMAL,
	gold_sell DECIMAL,
	gold_destroying_structure DECIMAL,
	gold_killing_heros DECIMAL,
	gold_killing_creeps DECIMAL,
	gold_killing_roshan DECIMAL,
	gold_killing_couriers DECIMAL,
	unit_order_none DECIMAL,
	unit_order_move_to_position DECIMAL,
	unit_order_move_to_target DECIMAL,
	unit_order_attack_move DECIMAL,
	unit_order_attack_target DECIMAL,
	unit_order_cast_position DECIMAL,
	unit_order_cast_target DECIMAL,
	unit_order_cast_target_tree DECIMAL,
	unit_order_cast_no_target DECIMAL,
	unit_order_cast_toggle DECIMAL,
	unit_order_hold_position DECIMAL,
	unit_order_train_ability DECIMAL,
	unit_order_drop_item DECIMAL,
	unit_order_give_item DECIMAL,
	unit_order_pickup_item DECIMAL,
	unit_order_pickup_rune DECIMAL,
	unit_order_purchase_item DECIMAL,
	unit_order_sell_item DECIMAL,
	unit_order_disassemble_item DECIMAL,
	unit_order_move_item DECIMAL,
	unit_order_cast_toggle_auto DECIMAL,
	unit_order_stop DECIMAL,
	unit_order_taunt DECIMAL,
	unit_order_buyback DECIMAL,
	unit_order_glyph DECIMAL,
	unit_order_eject_item_from_stash DECIMAL,
	unit_order_cast_rune DECIMAL,
	unit_order_ping_ability DECIMAL,
	unit_order_move_to_direction DECIMAL,
	unit_order_patrol DECIMAL,
	unit_order_vector_target_position DECIMAL,
	unit_order_radar DECIMAL,
	unit_order_set_item_combine_lock DECIMAL,
	unit_order_continue DECIMAL
);
CREATE TABLE player_time (
	match_id DECIMAL, 
	times DECIMAL, 
	gold_t_0 DECIMAL, 
	lh_t_0 DECIMAL, 
	xp_t_0 DECIMAL, 
	gold_t_1 DECIMAL, 
	lh_t_1 DECIMAL, 
	xp_t_1 DECIMAL, 
	gold_t_2 DECIMAL, 
	lh_t_2 DECIMAL, 
	xp_t_2 DECIMAL, 
	gold_t_3 DECIMAL, 
	lh_t_3 DECIMAL, 
	xp_t_3 DECIMAL, 
	gold_t_4 DECIMAL, 
	lh_t_4 DECIMAL, 
	xp_t_4 DECIMAL, 
	gold_t_128 DECIMAL, 
	lh_t_128 DECIMAL, 
	xp_t_128 DECIMAL, 
	gold_t_129 DECIMAL, 
	lh_t_129 DECIMAL, 
	xp_t_129 DECIMAL, 
	gold_t_130 DECIMAL, 
	lh_t_130 DECIMAL, 
	xp_t_130 DECIMAL, 
	gold_t_131 DECIMAL, 
	lh_t_131 DECIMAL, 
	xp_t_131 DECIMAL, 
	gold_t_132 DECIMAL, 
	lh_t_132 DECIMAL, 
	xp_t_132 DECIMAL
);
CREATE TABLE purchase_log (
	item_id DECIMAL, 
	time DECIMAL, 
	player_slot DECIMAL, 
	match_id DECIMAL
);
CREATE TABLE teamfights (
	match_id DECIMAL,
	start DECIMAL,
	"end" DECIMAL,
	last_death DECIMAL,
	deaths DECIMAL
);

CREATE TABLE teamfights_players (
	match_id DECIMAL,
	player_slot DECIMAL,
	buybacks DECIMAL,
	damage DECIMAL,
	deaths DECIMAL,
	gold_delta DECIMAL,
	xp_end DECIMAL,
	xp_start DECIMAL
);
CREATE TABLE test_labels (
	match_id DECIMAL,
	radiant_win DECIMAL
);
CREATE TABLE test_player (
	match_id DECIMAL,
	account_id DECIMAL,
	hero_id DECIMAL,
	player_slot DECIMAL
);
\copy ability_ids from './archive/ability_ids.csv' delimiter ',' csv header;
\copy ability_upgrades from './archive/ability_upgrades.csv' delimiter ',' csv header;
\copy cluster_regions from './archive/cluster_regions.csv' delimiter ',' csv header;
\copy hero_names from './archive/hero_names.csv' delimiter ',' csv header;
\copy item_ids from './archive/item_ids.csv' delimiter ',' csv header;
\copy match from './archive/match.csv' delimiter ',' csv header;
\copy match_outcomes from './archive/match_outcomes.csv' delimiter ',' csv header;
\copy objectives from './archive/objectives.csv' delimiter ',' csv header;
\copy patch_dates from './archive/patch_dates.csv' delimiter ',' csv header;
\copy player_ratings from './archive/player_ratings.csv' delimiter ',' csv header;
\copy players from './archive/players.csv' delimiter ',' csv header;
\copy player_time from './archive/player_time.csv' delimiter ',' csv header;
\copy purchase_log from './archive/purchase_log.csv' delimiter ',' csv header;
\copy teamfights from './archive/teamfights.csv' delimiter ',' csv header;
\copy teamfights_players from './archive/teamfights_players.csv' delimiter ',' csv header;
\copy test_labels from './archive/test_labels.csv' delimiter ',' csv header;
\copy test_player from './archive/test_player.csv' delimiter ',' csv header;
