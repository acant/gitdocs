# -*- encoding : utf-8 -*-

require 'active_record'

module Gitdocs
  class Initializer
    # @return [nil]
    def self.initialize_all
      initialize_database
      initialize_old_paths
    end

    # @return [nil]
    def self.initialize_database
      FileUtils.mkdir_p(root_dirname)
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: database
      )
      ActiveRecord::Migrator.migrate(
        File.expand_path('../migration', __FILE__)
      )
      Gitdocs::Share.reset_column_information
      Gitdocs::Configuration::Config.reset_column_information
    end

    # @return [nil]
    def self.initialize_old_paths
      old_path_dirname = File.expand_path('paths', root_dirname)
      return unless File.exist?(old_path_dirname)

      File.read(old_path_dirname).split("\n").each do |path|
        begin
          Share.create_by_path!(path)
        rescue # rubocop:disable HandleExceptions
          # Nothing to do, because we want the process to keep going.
        end
      end
    end

    # @return [String]
    def self.root_dirname
      @root_dirname ||= File.expand_path('.gitdocs', ENV['HOME'])
    end

    # @param [nil, String] value
    # @return [nil]
    def self.root_dirname=(value)
      return if value.nil?
      @root_dirname = value
    end

    # @return [String]
    def self.database
      @database ||= File.join(root_dirname, 'config.db')
    end

    # @param [nil, String] value
    # @return [nil]
    def self.database=(value)
      return if value.nil?
      @database = value
    end

    # @return [Boolean]
    def self.foreground
      @foreground ||= false
    end

    def self.foreground=(value)
      return if value.nil?
      @foreground = value
    end

    # @return [Boolean]
    def self.verbose
      @verbose ||= false
    end

    # @param [Boolean] value
    def self.verbose=(value)
      @verbose = !!value # rubocop:disable DoubleNegation
    end
  end
end
