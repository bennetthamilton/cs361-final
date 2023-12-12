#!/usr/bin/env ruby
class NullTrack
  def get_track_json
    '{"type": "Feature", "geometry": {"type": "MultiLineString", "coordinates": []}}'
  end
end

class NullWaypoint
  def get_waypoint_json(_indent = 0)
    '{"type": "Feature", "geometry": {"type": "Point", "coordinates": []}, "properties": {}}'
  end
end

class Track
  def initialize(segments, name=nil)
    @name = name
    @segments = segments.map { |s| TrackSegment.new(s) }
  end

  def get_track_json()
    j = '{"type": "Feature", '
    if @name
      j += '"properties": {"title": "' + @name + '"},'
    end
    j += '"geometry": {"type": "MultiLineString","coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '[' + "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
        tsj += ']'
      end
      j += tsj + ']'
    end
    j + ']}}'
  end
end


class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end


class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end


class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat  = lat
    @lon  = lon
    @ele  = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    j = '{"type": "Feature",'
    # if name is not nil or type is not nil
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"
    if ele
      j += ",#{@ele}"
    end
    j += ']},'
    if name || type 
      j += '"properties": {'
      if name 
        j += '"title": "' + @name + '"'
      end
      if type   # if type is not nil
        if name
          j += ','
        end
        j += '"icon": "' + @type + '"'  # type is the icon
      end
      j += '}'
    end
    j += "}"
    return j
  end
end


class World

  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(f)
    @features.append(t)
  end

  def to_geojson(indent=0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s += ","
      end
        if f.class == Track
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end
end


def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  # create instances of NullTrack and NullWaypoint
  null_track = NullTrack.new
  null_waypoint = NullWaypoint.new

  world = World.new("My Data", [w, w2, t, t2, null_track, null_waypoint])

  puts world.to_geojson()
end

if $PROGRAM_NAME == __FILE__
  main
end
