class ReportsController < ApplicationController
  PER_PAGE = 30

  def index
    authorize! :index, Report
    @reports = paginated_reports
    @page_name = t('report.heading')
  end

  def show
    @report = Report.get(params[:id])
    authorize! :show, @report
    send_data @report.data, :type => @report.content_type, :filename => @report.file_name
  end

  private

  def paginated_reports
    pagination_options = {
      :design_doc => 'Report',
      :view_name => 'by_as_of_date',
      :per_page => (params[:per_page] || PER_PAGE).to_i,
      :page => (params[:page] || 1).to_i,
      :include_docs => true,
      :descending => true
    }

    WillPaginate::Collection.create(pagination_options[:page], pagination_options[:per_page], Report.count) do |pager|
      pager.replace Report.paginate pagination_options
    end
  end
end
