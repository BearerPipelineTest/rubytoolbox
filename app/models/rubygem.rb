# frozen_string_literal: true

class Rubygem < ApplicationRecord
  self.primary_key = :name

  has_one :project,
          primary_key: :name,
          foreign_key: :rubygem_name,
          inverse_of:  :rubygem,
          dependent:   :destroy

  has_many :download_stats, -> { order(date: :asc) },
           class_name:  "Rubygem::DownloadStat",
           primary_key: :name,
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  has_many :trends, -> { order(date: :asc) },
           class_name:  "Rubygem::Trend",
           primary_key: :name,
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  has_many :rubygem_dependencies,
           -> { order(dependency_name: :asc) },
           foreign_key: :rubygem_name,
           inverse_of:  :rubygem,
           dependent:   :destroy

  has_many :reverse_dependencies,
           -> { order(rubygem_name: :asc) },
           class_name:  "RubygemDependency",
           foreign_key: :dependency_name,
           inverse_of:  :dependency,
           dependent:   :destroy

  def self.update_batch
    where("updated_at < ? ", 24.hours.ago.utc)
      .order(updated_at: :asc)
      .limit((count / 24.0).ceil)
      .pluck(:name)
  end

  def url
    File.join "https://rubygems.org/gems", name
  end

  def documentation_url
    super.presence || File.join("http://www.rubydoc.info/gems", name, "frames")
  end
end
