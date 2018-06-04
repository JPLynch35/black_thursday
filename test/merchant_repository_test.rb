require './test/test_helper'
require './lib/sales_engine'
require './lib/file_loader'
require './lib/merchant_repository'

class MerchantRepositoryTest < Minitest::Test
  def setup
    file_paths = { merchants:  './data/merchants.csv' }
    engine = SalesEngine.from_csv(file_paths)
    @merchants = engine.merchants
  end

  def test_it_exists
    assert_instance_of MerchantRepository, @merchants
  end

  def test_hash_tables_are_built
    id = @merchants.id
    assert_instance_of Hash, id
  end

  def test_all_returns_array_of_merchants
    all_merchants = @merchants.all
    actual1 = all_merchants[32].name
    actual2 = all_merchants[175].name
    assert_equal 'Princessfrankknits', actual1
    assert_equal 'CustomStringFling', actual2
  end

  def test_find_merchant_by_id
    actual1 = @merchants.find_by_id(12_334_213).name
    actual2 = @merchants.find_by_id(12_335_860).name
    assert_equal 'MuttisStrickwaren', actual1
    assert_equal 'Laboratori', actual2
  end

  def test_can_find_by_name
    fragment = 'style'
    actual = @merchants.find_all_by_name(fragment)
    assert_equal 3, actual.length
    assert_equal 'justMstyle', actual.first.name
    assert_equal 12337211, actual.last.id
  end

  def test_can_find_all_by_name
    actual1 = @merchants.find_by_name('keckenbauer')
    actual2 = @merchants.find_by_name('IronCompassFlight')
    assert_equal 12_334_123, actual1.id
    assert_equal 12_335_596, actual2.id
  end

  def test_can_find_last_element_id_plus_one
    expected = 12_337_412
    actual = @merchants.last_element_id_plus_one
    assert_equal expected, actual
  end

  def test_can_create_an_entry
    attributes =  {
                    name: 'Turing School of Hardware & Design'
                  }
    @merchants.create(attributes)
    actual = @merchants.all.last.name
    assert_equal 'Turing School of Hardware & Design', actual
  end

  def test_can_update_an_entry
    id = 12_334_261
    attributes = {
                   name: 'Bills Bowling Balls'
                 }
    actual1 = @merchants.find_by_id(id).name
    assert_equal 'esellermart', actual1
    @merchants.update(id, attributes)
    actual2 = @merchants.find_by_id(id).name
    assert_equal 'Bills Bowling Balls', actual2
  end

  def test_can_delete_by_id
    last_item = @merchants.all.last
    assert_instance_of Merchant, last_item
    last_id = last_item.id
    @merchants.delete(last_id)
    assert_nil @merchants.find_by_id(last_id)
  end

  def test_inspect_returnd_correct_string
    assert_equal '#<Array 475 rows>', @merchants.inspect
  end
end
