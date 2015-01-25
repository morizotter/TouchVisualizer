require 'zlib'

module Pod
  module Downloader
    class Http < Base
      def self.options
        [:type, :flatten, :sha1, :sha256]
      end

      class UnsupportedFileTypeError < StandardError; end

      private

      executable :curl
      executable :unzip
      executable :tar

      attr_accessor :filename, :download_path

      def download!
        @filename = filename_with_type(type)
        @download_path = (target_path + @filename)
        download_file(@download_path)
        verify_checksum(@download_path)
        extract_with_type(@download_path, type)
      end

      def type
        if options[:type]
          options[:type].to_sym
        else
          type_with_url(url)
        end
      end

      # @note   The archive is flattened if it contains only one folder and its
      #         extension is either `tgz`, `tar`, `tbz` or the options specify
      #         it.
      #
      # @return [Bool] Whether the archive should be flattened if it contains
      #         only one folder.
      #
      def should_flatten?
        if options.key?(:flatten)
          true
        elsif [:tgz, :tar, :tbz, :txz].include?(type)
          true # those archives flatten by default
        else
          false # all others (actually only .zip) default not to flatten
        end
      end

      def type_with_url(url)
        path = URI.parse(url).path
        if path =~ /.zip$/
          :zip
        elsif path =~ /.(tgz|tar\.gz)$/
          :tgz
        elsif path =~ /.tar$/
          :tar
        elsif path =~ /.(tbz|tar\.bz2)$/
          :tbz
        elsif path =~ /.(txz|tar\.xz)$/
          :txz
        else
          nil
        end
      end

      def filename_with_type(type = :zip)
        case type
        when :zip
          'file.zip'
        when :tgz
          'file.tgz'
        when :tar
          'file.tar'
        when :tbz
          'file.tbz'
        when :txz
          'file.txz'
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{type}"
        end
      end

      def download_file(full_filename)
        curl! %(-f -L -o #{full_filename.shellescape} "#{url}" --create-dirs)
      end

      def extract_with_type(full_filename, type = :zip)
        unpack_from = full_filename.shellescape
        unpack_to = @target_path.shellescape
        case type
        when :zip
          unzip! %(#{unpack_from} -d #{unpack_to})
        when :tgz
          tar! %(xfz #{unpack_from} -C #{unpack_to})
        when :tar
          tar! %(xf #{unpack_from} -C #{unpack_to})
        when :tbz
          tar! %(xfj #{unpack_from} -C #{unpack_to})
        when :txz
          tar! %(xf #{unpack_from} -C #{unpack_to})
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{type}"
        end

        # If the archive is a tarball and it only contained a folder, move its
        # contents to the target (#727)
        #
        if should_flatten?
          contents = @target_path.children
          contents.delete(target_path + @filename)
          entry = contents.first
          if contents.count == 1 && entry.directory?
            FileUtils.move(entry.children, target_path)
          end
        end
      end

      def compare_hash(filename, hasher, hash)
        incremental_hash = hasher.new

        File.open(filename, 'rb') do |file|
          buf = ''
          incremental_hash << buf while file.read(1024, buf)
        end

        computed_hash = incremental_hash.hexdigest

        if computed_hash != hash
          raise DownloaderError, 'Verification checksum was incorrect, ' \
            "expected #{hash}, got #{computed_hash}"
        end
      end

      # Verify that the downloaded file matches a sha1 hash
      #
      def verify_sha1_hash(filename, hash)
        require 'digest/sha1'
        compare_hash(filename, Digest::SHA1, hash)
      end

      # Verify that the downloaded file matches a sha256 hash
      #
      def verify_sha256_hash(filename, hash)
        require 'digest/sha2'
        compare_hash(filename, Digest::SHA2, hash)
      end

      # Verify that the downloaded file matches the hash if set
      #
      def verify_checksum(filename)
        if options[:sha256]
          verify_sha256_hash(filename, options[:sha256])
        elsif options[:sha1]
          verify_sha1_hash(filename, options[:sha1])
        end
      end
    end
  end
end
