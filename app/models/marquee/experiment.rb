module Marquee
  class Experiment < ApplicationRecord
    STATUSES = %w[draft running paused completed].freeze

    belongs_to :page
    has_many :variants, dependent: :destroy
    has_many :assignments, dependent: :destroy

    validates :name, presence: true
    validates :status, inclusion: { in: STATUSES }

    scope :running, -> { where(status: "running") }

    def results
      variants.map do |variant|
        assignment_count = assignments.where(variant: variant).count
        conversion_count = Lead.where(converted_experiment_id: id, converted_variant_id: variant.id).count
        conversion_rate = assignment_count > 0 ? (conversion_count.to_f / assignment_count * 100).round(2) : 0.0

        {
          variant_id: variant.id,
          variant_name: variant.name,
          is_control: variant.is_control,
          assignments: assignment_count,
          conversions: conversion_count,
          conversion_rate: conversion_rate
        }
      end
    end
  end
end
