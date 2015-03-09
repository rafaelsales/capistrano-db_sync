class Capistrano::DBSync::Postgres::FileNameGenerator
  def initialize(path)
    @path = path
    @sequence = 0
  end

  # Generates sequential file names.
  # Examples:
  # next("faceburger", :schema) => 0001-faceburger.schema
  # next("posts", :table)       => 0002-posts.table
  # next("comments", :table)    => 0003-comments.table
  def next(name, extension)
    raise ArgumentError unless [:schema, :table].include?(extension)
    @sequence += 1
    File.join(@path, "%04i-#{name}.#{extension}" % @sequence)
  end

  def self.extract_name(file_path)
    file_name = File.basename(file_path)
    file_name.scan(/\d+-(.*)\.(schema|table)$/).flatten.first
  end
end
