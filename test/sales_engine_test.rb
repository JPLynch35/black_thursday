require './test/test_helper'
require './lib/sales_engine'
require './lib/file_loader'

class SalesEngineTest < Minitest::Test

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
  end

  def test_attributes
    assert_instance_of SalesEngine, @engine
  end

  def test_it_creates_all_the_repositories
    assert_instance_of CustomerRepository, @engine.customers
    assert_instance_of InvoiceItemRepository, @engine.invoice_items
    assert_instance_of InvoiceRepository, @engine.invoices
    assert_instance_of ItemRepository, @engine.items
    assert_instance_of MerchantRepository, @engine.merchants
    assert_instance_of TransactionRepository, @engine.transactions
  end

  def test_sales_analyst_as_class_method
    assert_instance_of SalesAnalyst, @engine.analyst
  end
end
