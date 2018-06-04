module SalesAnalystHelper
  def elements_per_merchant(data_set)
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

  def items_with_high_units_prices(data_set, standard_deviation, average_price)
    data_set.map.with_index do |unit_price, index|
      if (unit_price - (2 * standard_deviation) - average_price).positive?
        @parent.items.all[index]
      end
    end.compact
  end

  def merchant_ids_with_high_invoice_count(invoices_per_merchant, standard_deviation, average_invoices)
    invoices_per_merchant.map.with_index do |num_invoices, index|
      if (num_invoices - (2 * standard_deviation) - average_invoices).positive?
        @parent.invoices.merchant_id.keys[index].to_i
      end
    end.compact
  end

  def merchant_ids_with_low_invoice_count(invoices_per_merchant, standard_deviation, average_invoices)
    invoices_per_merchant.map.with_index do |num_invoices, index|
      if (num_invoices + (2 * standard_deviation) - average_invoices).negative?
        @parent.invoices.merchant_id.keys[index].to_i
      end
    end.compact
  end

  def days_of_week_per_invoice(all_invoices)
    all_invoices.group_by do |invoice|
      invoice.created_at.wday
    end
  end

  def invoices_per_day_of_week(group_days_of_week)
    group_days_of_week.map do |day_number|
      day_number.count
    end
  end

  def days_with_high_invoice_count(days_of_week, invoices_per_day, standard_deviation, average_invoices)
    invoices_per_day.map.with_index do |num_invoices, index|
      if (num_invoices - standard_deviation - average_invoices).positive?
        Date::DAYNAMES[days_of_week.keys[index]]
      end
    end.compact
  end

  def invoice_item_totals(invoice_items_with_invoice_id)
    invoice_items_with_invoice_id.inject(0) do |collector, invoice_item|
      collector + (invoice_item.quantity.to_i * invoice_item.unit_price)
    end
  end
end
