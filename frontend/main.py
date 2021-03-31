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
    )
}

def query_main(query_num, sortby=None):
    if(query_num in qdict.keys()):
        header,cols,query = qdict[query_num]
        if(sortby is not None):
            query = 'select * from (' + query[:-1] +') as foo order by '+ cols[header.index(sortby)] +';'
            print(query)

    else:
        print("[ ERROR ] - Query not in Dictionary")
        return (None,None)
    conn = pg.connect(host='localhost',dbname='project_db', user='dhull', port='5432', password='1234')
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


app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/query',methods=['POST'])
def askquery():
    query = request.form['query']
    header,data = query_main(query)
    return render_template('index.html',header=header,data = data,typequery=query[0],prevq=query)

@app.route('/query',methods=['GET'])
def askquery_():
    query = request.args['q']
    sortby = request.args['sort']
    header,data = query_main(query,sortby)
    return render_template('index.html',header=header,data = data,typequery=query[0],prevq=query)

@app.route('/update',methods=['POST'])
def update():
    print(request.form)
    return render_template('index.html')

if __name__ == '__main__':
   app.run()
