require './test/test_helper'
require './lib/sales_engine'
require './lib/file_loader'
require './lib/sales_analyst'

class SalesAnalystHelperTest < Minitest::Test
  def setup
    file_paths =  {
                  customers:      './data/customers.csv',
                  invoice_items:  './data/invoice_items.csv',
                  invoices:       './data/invoices.csv',
                  items:          './data/items.csv',
                  merchants:      './data/merchants.csv',
                  transactions:   './data/transactions.csv'
                  }
    @engine = SalesEngine.from_csv(file_paths)
    @sales_analyst = @engine.analyst
  end

  def test_elements_per_merchant
    data_set = @engine.items.merchant_id.values
    actual = @sales_analyst.elements_per_merchant(data_set)
    assert_equal 475, actual.length
  end

  def test_can_calculate_merchant_ids_with_high_item_count
    data_set = @engine.items.merchant_id.values
    average_items = @sales_analyst.average_items_per_merchant
    standard_deviation = @sales_analyst.average_items_per_merchant_standard_deviation
    items_sold = @sales_analyst.elements_per_merchant(data_set)
    actual = @sales_analyst.merchant_ids_with_high_item_count(items_sold, standard_deviation, average_items)
    assert_equal 52, actual.length
  end

  def test_can_transform_merchant_ids_to_objects
    merchant_ids = [12334105, 12334112]
    actual = @sales_analyst.transform_merchant_ids_to_names(merchant_ids)
    assert_equal 'Shopin1901', actual.first.name
    assert_equal 'Candisart', actual.last.name
  end

  def test_can_calculate_unit_prices_per_merchant
    merchant_id = 12334146
    items = @engine.items.merchant_id[merchant_id.to_s]
    actual = @sales_analyst.unit_prices_per_merchant(items)
    assert_equal 7, actual.length
    assert_equal 30.00, actual.first.to_f
  end

  def test_can_return_to_big_decimal
    value = 34.62
    actual = @sales_analyst.return_to_big_decimal(value)
    assert_instance_of BigDecimal, actual
  end

  def test_can_calculate_sum_of_merchant_item_price_averages
    merchant_ids = [12334159, 12334195, 12334346]
    actual = @sales_analyst.sum_of_merchant_item_price_averages(merchant_ids)
    assert_equal 559.85, actual.to_f
  end

  def test_can_calculate_all_unit_prices
    actual = @sales_analyst.calculate_all_unit_prices
    assert_equal 1367, actual.length
    assert_equal 38.0, actual.last.to_f
  end

  def test_can_calculate_average_price_per_unit
    data_set = @sales_analyst.calculate_all_unit_prices
    actual = @sales_analyst.average_price_per_unit(data_set)
    assert_equal 251.06, actual
  end

  def test_can_calculate_items_with_high_units_prices
    data_set = @sales_analyst.calculate_all_unit_prices
    average_price = @sales_analyst.average_price_per_unit(data_set)
    standard_deviation = @sales_analyst.standard_deviation(data_set)
    actual = @sales_analyst.items_with_high_units_prices(data_set, standard_deviation, average_price)
    assert_equal 5, actual.length
    assert_instance_of Item, actual.first
  end

  def test_can_calculate_merchant_ids_with_high_invoice_count
    data_set = @engine.invoices.merchant_id.values
    average_invoices = @sales_analyst.average_invoices_per_merchant
    standard_deviation = @sales_analyst.average_invoices_per_merchant_standard_deviation
    invoices_per_merchant = @sales_analyst.elements_per_merchant(data_set)
    actual = @sales_analyst.merchant_ids_with_high_invoice_count(invoices_per_merchant, standard_deviation, average_invoices)
    assert_equal 12, actual.length
    assert_equal 12336266, actual[5]
  end

  def test_can_calculate_merchant_ids_with_low_invoice_count
    data_set = @engine.invoices.merchant_id.values
    average_invoices = @sales_analyst.average_invoices_per_merchant
    standard_deviation = @sales_analyst.average_invoices_per_merchant_standard_deviation
    invoices_per_merchant = @sales_analyst.elements_per_merchant(data_set)
    actual = @sales_analyst.merchant_ids_with_low_invoice_count(invoices_per_merchant, standard_deviation, average_invoices)
    assert_equal 4, actual.length
    assert_equal 12335560, actual[2]
  end

  def test_can_calculate_days_of_week_per_invoice
    all_invoices = @engine.invoices.all
    actual = @sales_analyst.days_of_week_per_invoice(all_invoices)
    assert_equal 7, actual.length
    assert_equal 708, actual[0].length
  end

  def test_can_calculate_invoices_per_day_of_week
    all_invoices = @engine.invoices.all
    days_of_week = @sales_analyst.days_of_week_per_invoice(all_invoices)
    group_days_of_week = days_of_week.values
    actual = @sales_analyst.invoices_per_day_of_week(group_days_of_week)
    assert_equal 7, actual.length
    assert_equal 729, actual[0]
  end

  def test_can_calculate_days_with_high_invoice_count
    all_invoices = @engine.invoices.all
    days_of_week = @sales_analyst.days_of_week_per_invoice(all_invoices)
    group_days_of_week = days_of_week.values
    invoices_per_day = @sales_analyst.invoices_per_day_of_week(group_days_of_week)
    average_invoices = @sales_analyst.calculate_mean(invoices_per_day).round(2)
    standard_deviation = @sales_analyst.standard_deviation(invoices_per_day)
    actual = @sales_analyst.days_with_high_invoice_count(days_of_week, invoices_per_day, standard_deviation, average_invoices)
    assert_equal 'Wednesday', actual.first
  end

  def test_can_calculate_invoice_item_totals
    invoice_id = 77
    invoice_items_with_invoice_id = @engine.invoice_items.find_all_by_invoice_id(invoice_id)
    actual = @sales_analyst.invoice_item_totals(invoice_items_with_invoice_id)
    assert_equal 2353.56, actual.to_f
  end
end
