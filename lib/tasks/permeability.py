# import libraries
import sys
import MySQLdb
import networkx as nx
# import matplotlib.pyplot as plt
import itertools
import json
import yaml
import os

import haversine
import jenks

# get project id: the one argument passed in to this script
projectId = sys.argv[1]

# set up graph
G = nx.Graph()

# establish connection to database
dbConfig = yaml.load(file(os.path.join(sys.path[0], '..', '..', 'config', 'database.yml'), 'r'))
if dbConfig.get('development'):
  user = dbConfig.get('development').get('username')
  passwd = dbConfig.get('development').get('password')
  db = dbConfig.get('development').get('database')
elif dbConfig.get('production'):
  user = dbConfig.get('production').get('username')
  passwd = dbConfig.get('production').get('password')
  db = dbConfig.get('production').get('database')
if passwd == None:
  passwd = ""
conn = MySQLdb.connect(host="localhost", user=user, passwd=passwd, db=db)
cursor = conn.cursor()

# connect and create nodes (which correspond with segments)
cursor.execute ('SELECT GROUP_CONCAT(gpos.segment_id) FROM geo_point_on_segments gpos INNER JOIN segments s ON gpos.segment_id = s.id WHERE s.project_id = {projectId} GROUP BY gpos.geo_point_id'.format(projectId = projectId))
lastGeoPointId = 0
for connectionSet in cursor.fetchall():
  segmentIds = connectionSet[0].split(',')
  # ignore if there is only one segment
  if len(segmentIds) == 2:
    G.add_edge(segmentIds[0], segmentIds[1])
    # print "edge from " + segmentIds[0] + " to: " + segmentIds[1]
  elif len(segmentIds) > 2:
    for combo in itertools.combinations(segmentIds, 2):
      G.add_edge(combo[0], combo[1])
      # print "edge from " + combo[0] + " to: " + combo[1]

# draw network plot
# nx.draw(G)
# plt.savefig("path.png")
# nx.write_dot(G,'path.dot')

# compute shortest paths
shortestPaths = nx.all_pairs_shortest_path(G)

# fetch segment lengths (which will be used for permeability computation)
# and set up permeability values dictionary
cursor.execute ('SELECT s.id, GROUP_CONCAT(gp.longitude), GROUP_CONCAT(gp.latitude) FROM segments s INNER JOIN geo_point_on_segments gpos ON gpos.segment_id = s.id INNER JOIN geo_points gp ON gp.id = gpos.geo_point_id WHERE s.project_id = {projectId} GROUP BY s.id'.format(projectId = projectId))
segmentLengths = {}
permeabilityValues = {}
for segment in cursor.fetchall():
  segmentId = segment[0]
  permeabilityValues[segmentId] = 0
  longitudes = segment[1].split(',')
  latitudes = segment[2].split(',')
  length = haversine.haversine(float(longitudes[0]), float(latitudes[0]), float(longitudes[1]), float(latitudes[1])) # km
  segmentLengths[segmentId] = length

# compute permeability
for origin, paths in shortestPaths.iteritems():
  for destination, path in paths.iteritems():
    multipliedDistance = segmentLengths[int(path[0])] * segmentLengths[int(path[-1])]
    for segment in path:
      permeabilityValues[int(segment)] = permeabilityValues[int(segment)] + multipliedDistance

breaks = jenks.getJenksBreaks(permeabilityValues.values(), 5)

permeabilityValues = [{'segment_id': segment, 'breakNum': jenks.classify(permeability, breaks), 'permeability': permeability} for segment, permeability in permeabilityValues.items()]

print json.dumps(permeabilityValues)