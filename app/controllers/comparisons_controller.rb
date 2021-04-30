# frozen_string_literal: true

class ComparisonsController < ApplicationController
  def show
    @projects = Project.where(permalink: requested_project_permalinks)
                       .for_display(forks: true)
                       .includes_associations
                       .order(current_order.sql)
                       .limit(50)
    @display_mode = display_mode
    enforce_canonical_query
  end

  private

  def enforce_canonical_query
    @expected_ids = @projects.map(&:permalink).sort.join(",")
    query_string = Rack::Utils.parse_nested_query(request.query_string).slice("display", "order").to_query
    destination = if query_string.present?
                    comparison_path(@expected_ids) + "?#{query_string}"
                  else
                    comparison_path(@expected_ids)
                  end

    redirect_to destination if selection_is_unordered?
  end

  def selection_is_unordered?
    params[:add].present? || (requested_project_permalinks.try(:join, ",").presence != @expected_ids.presence)
  end

  def requested_project_permalinks
    (params[:id].presence || "").split(",") + [params[:add]].filter_map { |id| id.try(:strip).presence }
  end

  def display_mode
    DisplayMode.new params[:display], default: "table"
  end

  def current_order
    @current_order ||= Project::Order.new order: params[:order]
  end
  helper_method :current_order
end
