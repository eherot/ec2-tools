#!/usr/bin/ruby

require 'rubygems'
require 'fog'
require 'date'

MAX_AGE_HOURLY=86400
MAX_AGE_DAILY=MAX_AGE_HOURLY*7
MAX_AGE_WEEKLY=MAX_AGE_DAILY*4
MAX_AGE_MONTHLY=MAX_AGE_WEEKLY*52

if ARGV[0]

  snap_set_name=ARGV[0]

else

  puts "Please specify a snapshot set to clean"
  exit 1

end

class CleanupSnapshots

  def initialize( snap_set_name )

    time_now=Time.now().to_i

    Fog.credentials_path = '/etc/fog.conf'
    @conn = Fog::Compute.new(:provider => "AWS")

    @conn.snapshots.each do |s|

      if s.description =~ /-#{snap_set_name}-/ &&
        s.description =~ /-(hourly|daily|weekly|monthly)-/ &&
        s.state == "completed"

        # e.g. "snap-HOME-hourly-20130204-0705"
        snap_date_str = s.description.split("-")[3,4].join
        d = DateTime.strptime(snap_date_str, "%Y%m%d%H%M")
        snap_date_i = Time.local(d.year,d.month,d.day,d.hour,d.min).to_i
        snap_age = time_now - snap_date_i

        case s.description
        when /hourly/

          if snap_age > MAX_AGE_HOURLY
            puts "Deleting snapshot #{s.id}/#{s.description}"
            @conn.delete_snapshot(s.id)
          end

        when /daily/

          if snap_age > MAX_AGE_DAILY
            puts "Deleting snapshot #{s.id}/#{s.description}"
            @conn.delete_snapshot(s.id)
          end

        when /weekly/

          if snap_age > MAX_AGE_WEEKLY
            puts "Deleting snapshot #{s.id}/#{s.description}"
            @conn.delete_snapshot(s.id)
          end

        when /monthly/

          if snap_age > MAX_AGE_MONTHLY
            puts "Deleting snapshot #{s.id}/#{s.description}"
            @conn.delete_snapshot(s.id)
          end

        end

      end

    end

  end

end

CleanupSnapshots.new( snap_set_name )
