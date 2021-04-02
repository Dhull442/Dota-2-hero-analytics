from flask import Flask, render_template, request
import psycopg2 as pg


# Queries Dictionary
qdict = {
    "gq1":(["Hero Name"],["hero_name"],
            "select min as hero_name from\
             ( select min(localized_name), count(1) \
             from players inner join hero_names using(hero_id) \
             group by hero_id order by count desc limit 10 ) foo\
             ;"),
    "gq2":(["Region", "Deaths"],["region","deaths"],
            "select region, deaths from\
            (\
                select match_id, max(deaths) as deaths\
                from teamfights\
                group by match_id\
\
            ) temp, match_cluster\
            where temp.match_id = match_cluster.match_id\
            order by deaths desc\
            limit 5\
            ;"),
    "gq3":(["Percentage of Radiant Wins"],["radiant_wins"],
            "select round(100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from\
            num_matches,\
            (\
                select count(1) from match\
                where radiant_win = 'True'\
            ) numerator\
            ;"),
    "gq4":(["Percentage of Dire Wins"],["radiant_wins"],
            "select round(100 - 100*(numerator.count/num_matches.num_matches ),2)as radiant_wins from\
            num_matches,\
            (\
                select count(1) from match\
                where radiant_win = 'True'\
            ) numerator\
            ;"),

    "hq1":(["Hero Name","Number of Matches","Pick Rate","Win Rate", "KDA"],["hero_name","num_matches_played","pick_rate","win_rate","KDA"],
            "select hero_name, count(1) as num_matches_played, round(100*(count(1)/min(num_matches)),2) as pick_rate, \
            round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,\
            round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA\
            from player_hero_wins, num_matches\
            group by hero_name\
            order by pick_rate desc, win_rate desc, hero_name\
        ;"),

    "hq2":(["Hero Name","Win Rate","Pick Rate", "KDA"],["hero_name","win_rate","pick_rate","KDA"],
            "select hero_name, \
            round(100*(sum(won::int)/cast(count(1) as decimal)),2) as win_rate,\
            round(100*(count(1)/min(num_matches)),2) as pick_rate,\
            round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA\
            from player_hero_wins, num_matches\
            group by hero_name\
            order by win_rate desc, pick_rate desc, hero_name\
            ;"
    ),

    "hq3":(
        ["Hero Name", "KDA", "Kills", "Deaths", "Assists"],["hero_name","KDA","K","D","A"],
        "select hero_name, \
        round((avg(K)+avg(A))/cast(avg(D) as decimal),2) as KDA,\
        round(avg(K),2) as K,\
        round(avg(D),2) as D,\
        round(avg(A),2) as A\
        from player_hero_wins, num_matches\
        group by hero_name\
        order by KDA desc, hero_name\
        ;"
    ),

    "hq4":(
        ["Hero Name","Gold Per Minute","Experience Per Minute"],["hero_name","gpm_f","xpm_f"],
        'select hero_name, round(avg(gpm),2) as gpm_f, round(avg(xppm),2) as xpm_f\
        from player_hero_wins\
        group by hero_name\
        order by gpm_f desc, xpm_f desc,hero_name\
        ;'
    ),

    "hq5":(
        ["Hero Name","Average Damage","Average Tower Damage","Average Healing"],["hero_name","avg_dmg","avg_tower_damage","avg_heal"],
        'select hero_name, round(avg(damage),2) as avg_dmg, round(avg(tower_damage),2) as avg_tower_damage,\
        round(avg(healing),2) as avg_heal\
        from player_hero_wins\
        group by hero_name\
        order by avg_dmg desc, avg_tower_damage desc, avg_heal desc, hero_name\
        ;'
    ),

    "hq6":(
        ["Hero Name"],["name"],
        'select localized_name as name from hero_names\
        order by localized_name\
        ;'
    ),

    "iq1":(
        ["Item Name", "Times purchased"],["item_name","times_purchased"],
        'select item_name, times_purchased from early_game\
        order by times_purchased desc;'
    ),
    "iq2":(
        ["Item Name", "Times purchased"],["item_name","times_purchased"],
        'select item_name, times_purchased from mid_game\
        order by times_purchased desc;'
    ),
    "iq3":(
        ["Item Name", "Times purchased"],["item_name","times_purchased"],
        'select item_name, times_purchased from end_game\
        order by times_purchased desc;'
    ),
    "iq4":(
        ["Item Name", "Win rate"],["item_name","win_rate"],
        'select item_name, win_rate from win_rate\
        order by win_rate desc;'
    ),
    "iq5":(
        ["Item Name"],["item_name"],
        'select item_name from item_ids;'
    ),

    "aq1":(
        ["Hero Name", "Gold Left"],["localized_name","gold"],
        'select localized_name, gold as gold_left\
        from player_hero\
        where gold > 15000\
        order by gold desc\
        ;'
    ),
    "aq2":(
        ["Hero Name", "Denies"],["localized_name","denies"],
        'select localized_name, denies\
        from player_hero\
        where denies > 40\
        order by denies desc\
        ;'
    ),
    "aq3":(
        ["Hero Name", "Hero XP"],["localized_name","xp_hero"],
        'select localized_name, xp_hero\
        from player_hero\
        where xp_hero > 24000\
        order by xp_hero desc\
        ;'
    ),
    "aq4":(
        ["Hero Name", "Creep XP"],["localized_name","xp_creep"],
        'select localized_name, xp_creep\
        from player_hero\
        where xp_creep > 26000\
        order by xp_creep desc\
        ;'
    ),
    "aq5":(
        ["Hero Name", "Stuns"],["localized_name", "stuns"],
        'select localized_name, stuns\
        from player_hero\
        where stuns > 300\
        order by stuns desc\
        ;'
    ),
    "aq6":(
       ["Region", "Positive Votes"],["region", "positive_votes"],
        'select region, positive_votes\
        from match_cluster\
        where positive_votes > 50\
        order by positive_votes desc\
        ;'
    ),
    "aq7":(
        ["Region", "Negative Votes"],["region","negative_votes"],
        'select region, negative_votes\
        from match_cluster\
        where negative_votes > 10\
        order by negative_votes desc\
        ;'
    ),
    "hsq1": (
        ["Hero Name", "Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"], [],
        '\
            select hero_name, item0, item1, item2, item3, item4, item5\
            from hero_builds\
            where rn=1\
            ;'
    ),
    "hsq2": (
        ["Hero Name", "Win rate"], [],
        """
        with hero1(p1_id) as
        (
            select hero_id from hero_names
            limit 1
        ),
        hero2(p2_id) as
        (
            select hero_id from hero_names
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

        select localized_name as hero_name, round(100*(h1.p1_wins/cast(h2.total_p1p2 as decimal)),2) as p1p2_winrate from
        (
            select foo2.hero_id, count(distinct foo1.match_id) as p1_wins from
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
            group by foo2.hero_id
        ) h1,
        (
            select foo2.hero_id, count(distinct foo1.match_id) as total_p1p2 from
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
            group by foo2.hero_id
        ) h2, hero_names
        where h1.hero_id = h2.hero_id and
        h2.hero_id = hero_names.hero_id
        ;
        """
    ),
    "hsq3": (
        ["Ability Build order", "Ability"], [],
        """
        with hero1(p1_id) as
        (
            select hero_id from hero_names
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
        select a.nr as order, a.ability from (
            select ability_order, count(*) as count from (
                select hero_id, array_agg(ability_name order by time) as ability_order from
                hero_ability
                group by hero_id, slot, match_id
            ) temp
            group by hero_id, ability_order
            order by count desc
            limit 1
        ) temp2, unnest(temp2.ability_order) with ordinality a(ability, nr)
        ;
        """
    )
}

def query_main(query_num, sortby=None, hero_name=None, order=None):
    if(query_num in qdict.keys()):
        header,cols,query = qdict[query_num]
        if(sortby is not None):
            query = 'select * from (' + query[:-1] +') as foo order by '+ cols[header.index(sortby)] + ' ' +order +';'

        if hero_name is not None and query_num.startswith("hsq"):
            if query_num == "hsq1":
                query = 'select * from (' + query[:-1] +') as foo where hero_name = \''+ hero_name +'\';'
            else:
                query = query[:83] +'where localized_name = \''+ hero_name +'\'\n' + query[84:]
                print(query)


    else:
        print("[ ERROR ] - Query not in Dictionary")
        return (None,None)
    conn = pg.connect(host='localhost',dbname='project_db', user='dronemist', port='5432', password='')
    # conn = pg.connect(host='localhost',dbname='project_db', user='dhull', port='5432', password='1234')

    data = None
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        data = cursor.fetchall()
    except (Exception, pg.Error) as error:
        print("Error while fetching data from PostgreSQL", error)
    finally:
        if conn is not None:
            cursor.close()
            conn.close()
            return (header,data)

all_heros_query = "hq6"

app = Flask(__name__)

def get_all_heros():
    header, data = query_main(all_heros_query)
    return data

@app.route('/')
def home():
    return render_template('index.html', all_heros = get_all_heros())

@app.route('/query',methods=['POST'])
def askquery():
    query = request.form['query']
    header,data = query_main(query)
    return render_template('index.html',header=header,data = data,typequery=query[0],prevq=query, all_heros = get_all_heros())

@app.route('/query',methods=['GET'])
def askquery_():
    query = request.args['q']
    sortby = request.args['sort']
    order = request.args['order']
    header,data = query_main(query,sortby,order=order)
    if(order=='desc'):
        return render_template('index.html',header=header,data = data,typequery=query[0],prevq=query, all_heros = get_all_heros())
    else:
        return render_template('index.html',header=header,data = data,prevh = sortby,typequery=query[0],prevq=query, all_heros = get_all_heros())

@app.route('/hero',methods=['POST'])
def hero():
    query = request.form['query']
    hero_name = request.form['hero_name']
    header,data = query_main(query,hero_name = hero_name)
    return render_template('index.html',header=header,data = data,typequery="hs",prev_hero_name=hero_name,prevq=query,all_heros = get_all_heros())

@app.route('/update',methods=['POST'])
def update():
    # print("Hi")
    print(request.form)
    if(request.form['password']=='1234'):
        print("Do update")
    else:
        print("no update sorry")
        # do stuff
    return render_template('index.html', all_heros = get_all_heros())

if __name__ == '__main__':
   app.run()
