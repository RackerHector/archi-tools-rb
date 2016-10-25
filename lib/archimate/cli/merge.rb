# frozen_string_literal: true
module Archimate
  module Cli
    class Merge
      attr_reader :base, :local, :remote, :merged, :aio

      def self.merge(base_file, remote_file, local_file, merged_file, aio = Archimate::AIO.new(verbose: true))
        aio.debug "#{DateTime.now}: Reading base file: #{base_file}"
        base = Archimate::ArchiFileReader.read(base_file)
        aio.debug "#{DateTime.now}: Reading local file: #{local_file}"
        local = Archimate::ArchiFileReader.read(local_file)
        aio.debug "#{DateTime.now}: Reading remote file: #{remote_file}"
        remote = Archimate::ArchiFileReader.read(remote_file)
        aio.debug "#{DateTime.now}: Merged file is #{merged_file}"
        merged = merged_file

        my_merge = Merge.new(base, local, remote, merged, aio)
        my_merge.merge
      end

      def initialize(base, local, remote, merged, aio)
        @base = base
        @local = local
        @remote = remote
        @merged = merged
        @aio = aio
      end

      def merge
        aio.debug "#{DateTime.now}: Starting merging"
        merge = Archimate::Diff::Merge.three_way(base, local, remote, aio)
        aio.debug "#{DateTime.now}: Done merging"
        aio.debug "Conflicts:"
        aio.debug merge.conflicts
      end
    end
  end
end
