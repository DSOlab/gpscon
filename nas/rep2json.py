#! /usr/bin/python

import sys
import datetime
import MySQLdb
import json

rep_file = sys.argv[1]
DB_HOST="147.102.110.73"
DB_USER="xanthos"
DB_PASS="koko1"
DB_NAME="procsta"

def parse_rep_line(line):
    ''' Parse a *.rep line; this will return a tuple (epoch, dict), where epoch
        is a datetime.datetime instance and the dict is a dictionary of type
        [key(=station_name): value(=file_size)]
    '''
    if len(line)<=1: return None, {}
    l     = line.split()
    epoch = datetime.datetime.strptime(l[0], '%Y-%m-%d')
    ld    = {}
    for key, val in [(l[i],l[i+1]) for i in range(1,len(l),2)]: ld[key] = val
    return epoch, ld

def get_db_info(station):
    ''' Query the database for information on a given station
    '''
    status    = 0
    db_answer = ''
    ERR_MSG   = ''
    try:
        db  = MySQLdb.connect(
                host   = DB_HOST,
                user   = DB_USER,
                passwd = DB_PASS,
                db     = DB_NAME
            )
        cur = db.cursor()
        ## ok, connected to db; now start quering for each station
        QUERY='SELECT station.station_id, station.mark_name_DSO, stacode.mark_name_OFF, stacode.station_name, ftprnx.dc_name, ftprnx.protocol, ftprnx.url_domain, ftprnx.pth2rnx30s, ftprnx.pth2rnx01s, ftprnx.ftp_usname, ftprnx.ftp_passwd, network.network_name, dataperiod.periodstart, dataperiod.periodstop, station.ecef_X, station.ecef_Y, station.ecef_Z, station.longitude_east, station.latitude_north, station.ellipsoidal_height FROM station JOIN stacode ON station.stacode_id=stacode.stacode_id JOIN dataperiod ON station.station_id=dataperiod.station_id JOIN ftprnx ON dataperiod.ftprnx_id=ftprnx.ftprnx_id JOIN  sta2nets ON sta2nets.station_id=station.station_id JOIN network ON network.network_id=sta2nets.network_id WHERE station.mark_name_DSO="%s";'%station
        cur.execute( QUERY )
        try:
            SENTENCE = cur.fetchall()
            # answer must only have one raw
            if len(SENTENCE) > 1:
                ## station belongs to more than one networks; see bug #13
                print >> sys.stderr, '[WARNING] station \"%s\" belongs to more than one networks.'%station
                add_sta  = True
                ref_line = SENTENCE[0]
                for idx in [1, 2, 3]+range(14,len(SENTENCE)):
                    for sent in SENTENCE:
                        if sent[idx] != ref_line[idx]:
                            add_sta = False
                            print >> sys.stderr, '[ERROR] Station \"%s\" belongs to more than one networks but independent fields don\'t match!'%station
                            print >> sys.stderr, '        Field:',sent[idx],'~',ref_line[idx]
                            status = 4
                if add_sta is True :
                    db_answer = SENTENCE[0]
            elif len(SENTENCE) == 0:
                print >> sys.stderr, '[ERROR] Cannot match station \"%s\" in the database.'%station
                status = 3
            else:
                db_answer = SENTENCE[0]
        except:
            print '[ERROR] No matching station name in database for \"%s\".'%station
            ERR_MSG = sys.exc_info()[0]
            status = 2
    except:
        ERR_MSG = sys.exc_info()[0]
        print '[ERROR] Failed connecting to the database'
        status = 1

    if status > 0:
        #print >> sys.stderr, '        ',ERR_MSG, "STATUS =",status
        return {}

    return {'official_name':db_answer[2],
            'station_name' :db_answer[3],
            'data_center'  :db_answer[4],
            'x_ecef'       :db_answer[14],
            'y_ecef'       :db_answer[15],
            'z_ecef'       :db_answer[16],
            'longtitude'   :db_answer[17],
            'latitude'     :db_answer[18],
            'height'       :db_answer[19]
            }

data_dict = {}
with open(rep_file, 'r') as fin:
    ''' Read a rep file and create a dictionary with key=station_name, value=
        an array of dictionaries key=epoch:val=size. E.g. 
        'station':[{'epoch': datetime.datetime(2009, 1, 1, 0, 0), 'size': '331626'},...]
    '''
    for line in fin.readlines():
        ## TODO json cannot serialize datetime instances; casting this to str
        epoch, tmp_dict = parse_rep_line(line)
        epoch = str(epoch)
        for station, size in tmp_dict.iteritems():
            if station in data_dict:
                data_dict[station].append({"epoch":epoch, "size":size})
            else:
                data_dict[station] = [{"epoch":epoch, "size":size}]


##  Query the database for info on all the stations; the stations that we
##+ are not able to find database entries for, will be deleted
sta_to_delete = []
info_dict = {}
for key in data_dict:
    info_dict_tmp = get_db_info(key)
    if info_dict_tmp == {}:
        print >> sys.stderr, '[WARNING] Db query failed for station %s; station skiped'%key
        sta_to_delete.append(key)
    else:
        info_dict[key] = info_dict_tmp

for i in sta_to_delete: del data_dict[i]

##  Compile the final list
final_list = [ {"name":i,"info":info_dict[i],"data":data_dict[i]} for i in data_dict ]
##  and dump it as json
print json.dumps( final_list, indent=2, separators=(',\n', ':') )
