xml.instruct!
xml.kml("xmlns" => "http://www.opengis.net/kml/2.2") do
  xml.Document do
    xml.name @project.name
    xml.description "Exported from #{@project.kind_display} at #{Time.now}. Version #{@project.version} of the project map."
    xml.Style :id => 'black-segment-line' do
      xml.LineStyle do
        xml.color "ff000000"
        xml.width 5
      end
    end
    ## This style can be used if we want to mark segments used as gates.
    # xml.Style :id => 'blue-segment-line' do
    #   xml.LineStyle do
    #     xml.color "ffff0000"
    #     xml.width 5
    #   end
    # end
    for segment in @project.segments
      xml.Placemark do
        xml.name "segment-#{segment.id}"
        xml.styleUrl "#black-segment-line"
        # if segment.gates.length > 0
        #   xml.styleUrl "#blue-segment-line"
        # else
        #   xml.styleUrl "#black-segment-line"
        # end
        xml.LineString do
          xml.coordinates "#{segment.start_longitude},#{segment.start_latitude} #{segment.end_longitude},#{segment.end_latitude}\n"
        end
      end
    end
  end
end