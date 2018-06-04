require './test/test_helper'
require './lib/sales_engine'
require './lib/file_loader'
require './lib/item_repository'

class ItemRepositoryTest < Minitest::Test

  def setup
    file_paths = { items:      './data/items.csv' }
    engine = SalesEngine.from_csv(file_paths)
    @items = engine.items
  end

  def test_it_exists
    assert_instance_of ItemRepository, @items
  end

  def test_hash_tables_are_built
    merchant_id = @items.merchant_id
    assert_instance_of Hash, merchant_id
  end

  def test_all_returns_array_of_items
    all_items = @items.all
    actual1 = all_items[46].merchant_id
    actual2 = all_items[147].merchant_id
    assert_equal '12334397', actual1
    assert_equal '12334941', actual2
  end

  def test_can_find_by_id
    actual = @items.find_by_id(263_395_237).name
    assert_equal '510+ RealPush Icon Set', actual
  end

  def test_can_find_by_name
    actual1 = @items.find_by_name('510+ RealPush Icon Set')
    actual2 = @items.find_by_name('Handmade Green Check Wool Cushion')
    assert_equal 263_395_237, actual1.id
    assert_equal 263_456_059, actual2.id
  end

  def test_can_find_all_with_description
    description1 = (
      'Exotic Women&#39;s or Men&#39;s Handmade Bracelet or Anklet.  Sizes from 6 inches to 9 inches.  Made with premium crafted beads.  You may request colors and styles.  Most are made to order.  Email me after order is placed for specific or custom handmade designs, etc.'
                    )
    actual1 = @items.find_all_with_description(description1)
    assert_equal 1, actual1.length
  end

  def test_can_find_all_by_price
    price1 = BigDecimal(60_000.to_i) / 100
    price2 = BigDecimal(1_600.to_i) / 100
    actual1 = @items.find_all_by_price(price1)
    actual2 = @items.find_all_by_price(price2)
    assert_equal 6, actual1.length
    assert_equal 2, actual2.length
  end

  def test_can_find_all_by_price_in_range
    range1 = (1000.00..1500.00)
    range2 = (10.00..150.00)
    actual1 = @items.find_all_by_price_in_range(range1)
    actual2 = @items.find_all_by_price_in_range(range2)
    assert_equal 19, actual1.length
    assert_equal 910, actual2.length
  end

  def test_can_find_all_by_merchant_id
    actual1 = @items.find_all_by_merchant_id(12_335_963)
    actual2 = @items.find_all_by_merchant_id(12_336_081)
    assert_equal 12, actual1.length
    assert_equal 13, actual2.length
  end

  def test_can_find_last_element_id_plus_one
    expected = 263_567_475
    actual = @items.last_element_id_plus_one
    assert_equal expected, actual
  end

  def test_can_create_an_entry
    attributes =  {
                    name: "Capita Defenders of Awesome 2018",
                    description: "This board both rips and shreds",
                    unit_price: BigDecimal(399.99, 5),
                    created_at: Time.now,
                    updated_at: Time.now,
                    merchant_id: 25
                  }
    @items.create(attributes)
    actual = @items.all.last.description
    assert_equal 'This board both rips and shreds', actual
  end

  def test_can_update_an_entry
    id = 263567474
    attributes = {
                   unit_price: BigDecimal.new(379.99, 5)
                 }
    actual1 = @items.find_by_id(id).unit_price
    assert_equal 38, actual1
    @items.update(id, attributes)
    actual2 = @items.find_by_id(id).unit_price
    assert_equal BigDecimal.new(379.99, 5), actual2
  end

  def test_can_delete_by_id
    last_item = @items.all.last
    assert_instance_of Item, last_item
    last_id = last_item.id
    @items.delete(last_id)
    assert_nil @items.find_by_id(last_id)
  end

  def test_inspect_returnd_correct_string
    assert_equal '#<Array 1367 rows>', @items.inspect
  end
end
