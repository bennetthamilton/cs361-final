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

  def get_track_json
    '{"type": "Feature", ' \
      "#{properties_json}" \
      '"geometry": {"type": "MultiLineString","coordinates": [' \
      "#{segments_json}" \
      ']}}'
  end

  private

  def properties_json
    return '' unless @name

    '"properties": {"title": "' + @name + '"},'
  end

  def segments_json
    @segments.map.with_index do |s, index|
      "#{',' if index.positive?}[#{coordinates_json(s)}]"
    end.join('')
  end

  def coordinates_json(segment)
    segment.coordinates.map do |c|
      '[' + "#{c.longitude},#{c.latitude}" + (c.elevation ? ",#{c.elevation}" : '') + ']'
    end.join(',')
  end
end


class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end


class Point
  attr_reader :latitude, :longitude, :elevation

  def initialize(longitude, latitude, elevation=nil)
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
  end
end


class Waypoint
  attr_reader :latitude, :longitude, :elevation, :name, :type

  def initialize(longitude, latitude, elevation=nil, name=nil, type=nil)
    @latitude  = latitude
    @longitude  = longitude
    @elevation  = elevation
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    '{"type": "Feature", ' \
      '"geometry": {"type": "Point","coordinates": ' \
      "[#{@longitude},#{@latitude}#{",#{@elevation}" if elevation}]}," \
      "#{build_properties_json}}"
  end

  private

  def build_properties_json()
    if name || type 
      properties = '"properties": {'
      properties += '"title": "' + @name + '"' if name
      if type   # if type is not nil
        properties += ',' if name
        properties += '"icon": "' + @type + '"'  # type is the icon
      end
      properties += '}'
    end
    properties
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
