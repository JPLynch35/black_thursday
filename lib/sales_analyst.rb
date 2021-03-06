require_relative 'mathematics'
require_relative 'sales_analyst_helper'
require_relative 'customer_analytics'
require_relative 'customer_analytics_helper'
require 'bigdecimal/util'

class SalesAnalyst
  include Mathematics
  include SalesAnalystHelper
  include CustomerAnalytics
  include CustomerAnalyticsHelper

  def initialize(parent)
    @parent = parent
  end

  def average_items_per_merchant
    items_by_merchant_id = @parent.items.merchant_id.values
    calculate_mean(find_elements_per_merchant(items_by_merchant_id)).round(2)
  end

  def average_items_per_merchant_standard_deviation
    items_by_merchant_id = @parent.items.merchant_id.values
    standard_deviation(find_elements_per_merchant(items_by_merchant_id))
  end

  def merchants_with_high_item_count
    items_by_merchant_id = @parent.items.merchant_id.values
    average_items = average_items_per_merchant
    standard_deviation = average_items_per_merchant_standard_deviation
    items_sold = find_elements_per_merchant(items_by_merchant_id)
    merchant_ids = find_merchant_ids_with_high_item_count(items_sold, standard_deviation, average_items)
    transform_merchant_ids_to_names(merchant_ids)
  end

  def average_item_price_for_merchant(merchant_id)
    items = @parent.items.merchant_id[merchant_id.to_s]
    unit_prices = find_unit_prices_per_merchant(items)
    mean = calculate_mean(unit_prices)
    return_to_big_decimal(mean)
  end

  def average_average_price_per_merchant
    merchant_ids = @parent.items.merchant_id.keys
    sum = sum_of_merchant_item_price_averages(merchant_ids)
    average_average = sum / merchant_ids.length
    return_to_big_decimal(average_average)
  end

  def golden_items
    units_prices_by_item = calculate_all_unit_prices
    average_price = find_average_price_per_unit(units_prices_by_item)
    standard_deviation = standard_deviation(units_prices_by_item)
    find_items_with_high_units_prices(units_prices_by_item, standard_deviation, average_price)
  end

  def average_invoices_per_merchant
    invoices_by_merchant_id = @parent.invoices.merchant_id.values
    calculate_mean(find_elements_per_merchant(invoices_by_merchant_id)).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    invoices_by_merchant_id = @parent.invoices.merchant_id.values
    standard_deviation(find_elements_per_merchant(invoices_by_merchant_id))
  end

  def top_merchants_by_invoice_count
    invoices_by_merchant_id = @parent.invoices.merchant_id.values
    average_invoices = average_invoices_per_merchant
    standard_deviation = average_invoices_per_merchant_standard_deviation
    invoices_per_merchant = find_elements_per_merchant(invoices_by_merchant_id)
    merchant_ids = find_merchant_ids_with_high_invoice_count(invoices_per_merchant, standard_deviation, average_invoices)
    transform_merchant_ids_to_names(merchant_ids)
  end

  def bottom_merchants_by_invoice_count
    invoices_by_merchant_id = @parent.invoices.merchant_id.values
    average_invoices = average_invoices_per_merchant
    standard_deviation = average_invoices_per_merchant_standard_deviation
    invoices_per_merchant = find_elements_per_merchant(invoices_by_merchant_id)
    merchant_ids = find_merchant_ids_with_low_invoice_count(invoices_per_merchant, standard_deviation, average_invoices)
    transform_merchant_ids_to_names(merchant_ids)
  end

  def top_days_by_invoice_count
    all_invoices = @parent.invoices.all
    days_of_week = find_days_of_week_per_invoice(all_invoices)
    group_days_of_week = days_of_week.values
    invoices_per_day = find_invoices_per_day_of_week(group_days_of_week)
    average_invoices = calculate_mean(invoices_per_day).round(2)
    standard_deviation = standard_deviation(invoices_per_day)
    find_days_with_high_invoice_count(days_of_week, invoices_per_day, standard_deviation, average_invoices)
  end

  def invoice_status(status)
    all_status = @parent.invoices.status[status]
    count_status = all_status.length
    count_all = @parent.invoices.all.length
    find_percentage(count_status, count_all)
  end

  def invoice_paid_in_full?(invoice_id)
    successful_transaction = @parent.transactions.result[:success]
    successful_transaction.any? do |transaction|
      transaction.invoice_id == invoice_id
    end
  end

  def invoice_total(invoice_id)
    if invoice_paid_in_full?(invoice_id)
      invoice_items_with_invoice_id = @parent.invoice_items.find_all_by_invoice_id(invoice_id)
      find_invoice_item_totals(invoice_items_with_invoice_id)
    end
  end
end
