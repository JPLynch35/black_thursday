require 'minitest/autorun'
require 'minitest/pride'
require './lib/customer_analytics_helper'
require './lib/sales_analyst'
require './lib/sales_engine'
require 'bigdecimal'

class SalesAnalystTest < Minitest::Test
  def setup
    file_paths = {
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

  def test_can_calculate_totals_per_customer
    customer_invoices = @engine.invoices.customer_id.values

    assert_equal 901, @sales_analyst.calculate_totals_per_customer(customer_invoices).length
    assert_instance_of BigDecimal, @sales_analyst.calculate_totals_per_customer(customer_invoices)[0]
  end

  def test_can_find_ids_for_top_customers
    customer_ids = @engine.invoices.customer_id.keys
    customer_invoices = @engine.invoices.customer_id.values
    customer_totals = @sales_analyst.calculate_totals_per_customer(customer_invoices)
    customers_ids_and_totals = Hash[customer_ids.zip(customer_totals)]


    assert_equal 7, @sales_analyst.find_ids_for_top_customers(customers_ids_and_totals, top_customers = 7).length
  end

  def test_can_find_customers_by_customer_id
    top_customers = 5
    customer_ids = @engine.invoices.customer_id.keys
    customer_invoices = @engine.invoices.customer_id.values
    customer_totals = @sales_analyst.calculate_totals_per_customer(customer_invoices)
    customer_ids_and_totals = Hash[customer_ids.zip(customer_totals)]
    ids_for_top_customers = @sales_analyst.find_ids_for_top_customers(customer_ids_and_totals, top_customers)

    assert_equal 5, @sales_analyst.find_customers_from_customer_ids(ids_for_top_customers).length
    assert_instance_of Customer, @sales_analyst.find_customers_from_customer_ids(ids_for_top_customers)[0]
  end

  def test_can_calculate_number_of_items_per_invoice
    invoice_id = 1

    assert_equal 47, @sales_analyst.calculate_number_of_items_per_invoice(invoice_id)
  end

  def test_can_calculate_quantity_for_invoices
    customer_id = 100
    invoices_for_customer = @engine.invoices.customer_id[customer_id]

    assert_equal 3, @sales_analyst.calculate_quantity_for_invoices(invoices_for_customer).compact.length
  end

  def test_if_customers_made_single_purchase
    invoices_per_customer = @engine.invoices.customer_id.values

    assert_equal 76, @sales_analyst.customers_with_single_purchase(invoices_per_customer).length
    assert_instance_of Customer, @sales_analyst.customers_with_single_purchase(invoices_per_customer)[0]
  end

  def test_can_find_all_customer_invoice_items
    year = 2012
    customer_id = 2
    customer_invoices = @engine.invoices.find_all_by_customer_id(customer_id)

    assert_equal 0, @sales_analyst.find_all_customer_invoice_items(customer_invoices, year).length
  end

  def test_can_find_invoice_items_per_customer
    customer_id = 2
    invoices_per_customer = @engine.invoices.find_all_by_customer_id(customer_id)

    assert_equal 16, @sales_analyst.find_invoice_items_per_customer(invoices_per_customer).length
    assert_instance_of InvoiceItem, @sales_analyst.find_invoice_items_per_customer(invoices_per_customer)[0]
  end

  def test_can_find_item_id_quantities
    customer_id = 2
    invoice = @engine.invoices.find_all_by_customer_id(customer_id)
    invoice_id = invoice.first.id
    invoice_items = @engine.invoice_items.find_all_by_invoice_id(invoice_id)

    assert_equal 3, @sales_analyst.find_item_id_quantities(invoice_items).values.length
    assert_equal 10, @sales_analyst.find_item_id_quantities(invoice_items).values[0]

  end

  def test_can_find_customers_with_unpaid_invoices
    unpaid_invoices = @engine.invoices.all.map do |invoice|
      invoice_id = invoice.id
      invoice unless @sales_analyst.invoice_paid_in_full?(invoice_id)
      end.compact

    assert_equal 786, @sales_analyst.find_customers_with_unpaid_invoices(unpaid_invoices).length
  end

  def test_find_invoice_items_by_invoices
    paid_invoices = @sales_analyst.find_paid_invoices

    assert_equal 2810, @sales_analyst.find_invoice_items_by_invoices(paid_invoices).length
  end

  def test_find_revenue_by_invoice
    paid_invoices = @sales_analyst.find_paid_invoices
    invoice_items_by_invoices = @sales_analyst.find_invoice_items_by_invoices(paid_invoices)

    assert_equal 2810, @sales_analyst.find_revenue_by_invoice(invoice_items_by_invoices).length
    assert_instance_of Float, @sales_analyst.find_revenue_by_invoice(invoice_items_by_invoices)[0]
  end

  def test_find_quantity_by_invoice
    paid_invoices = @sales_analyst.find_paid_invoices
    invoice_items_by_invoices = @sales_analyst.find_invoice_items_by_invoices(paid_invoices)

    assert_equal 2810, @sales_analyst.find_quantity_by_invoice(invoice_items_by_invoices).length
  end

  def test_find_invoice_of_max_value
    paid_invoices = @sales_analyst.find_paid_invoices
    invoice_items_by_invoices = @sales_analyst.find_invoice_items_by_invoices(paid_invoices)
    revenue_by_invoice = @sales_analyst.find_revenue_by_invoice(invoice_items_by_invoices)

    assert_instance_of Invoice, @sales_analyst.find_invoice_of_max_value(revenue_by_invoice, paid_invoices)
    assert_equal 3394, @sales_analyst.find_invoice_of_max_value(revenue_by_invoice, paid_invoices).id
  end
end
