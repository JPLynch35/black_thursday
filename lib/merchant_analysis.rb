module MerchantAnalysis
  def items_per_merchant(data_set)
    data_set.map do |data|
      data.length
    end
  end

  def merchant_ids_with_high_item_count(items_sold, standard_deviation, average_items)
    items_sold.map.with_index do |num_of_items, index|
      if (num_of_items - standard_deviation - average_items).positive?
        @parent.items.merchant_id.keys[index].to_i
      end
    end.compact
  end

  def transform_merchant_ids_to_names(merchant_ids)
    merchant_ids.map do |id|
      @parent.merchants.id[id].first
    end
  end

  def unit_prices_per_merchant(items)
    items.map do |item|
      item.unit_price
    end
  end

  def return_to_big_decimal(value)
    value.round(2).to_d
  end

  def sum_of_merchant_item_price_averages(merchant_ids)
    merchant_ids.inject(0) do |sum, merchant_id|
      sum + average_item_price_for_merchant(merchant_id)
    end
  end

  def calculate_all_unit_prices
    @parent.items.all.map do |item|
      item.unit_price
    end
  end

  def average_price_per_unit(data_set)
    calculate_mean(data_set).round(2)
  end
end
