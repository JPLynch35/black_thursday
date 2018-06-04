module CustomerAnalyticsHelper
  def calculate_totals_per_customer(customer_invoices)
    customer_invoices.map do |invoices|
      totals = invoices.map do |invoice|
        invoice_total(invoice.id)
      end.compact
      sum_all(totals)
    end
  end

  def find_ids_for_top_customers(customer_ids_and_totals, top_customers)
    customer_ids_and_totals.values.max(top_customers).map do |customer_total|
      customer_ids_and_totals.key(customer_total)
    end
  end

  def find_customers_from_customer_ids(ids_for_top_customers)
    ids_for_top_customers.map do |customer_id|
      @parent.customers.find_by_id(customer_id)
    end
  end

  def calculate_number_of_items_per_invoice(invoice_id)
    if invoice_paid_in_full?(invoice_id)
      invoice_items_per_invoice = @parent.invoice_items.find_all_by_invoice_id(invoice_id)
      invoice_items_per_invoice.inject(0) do |sum, invoice_items|
        sum + invoice_items.quantity.to_i
      end
    end
  end

  def calculate_quantity_for_invoices(invoices_for_customer)
    invoices_for_customer.map do |invoice|
      invoice_id = invoice.id
      calculate_number_of_items_per_invoice(invoice_id)
    end
  end

  def customers_with_single_purchase(invoices_per_customer)
    invoices_per_customer.map do |all_invoices|
      if all_invoices.length == 1
        one_time_buyer_id = all_invoices.first.customer_id
        @parent.customers.find_by_id(one_time_buyer_id)
      end
    end.compact
  end

  def find_all_customer_invoice_items(customer_invoices, year)
    customer_invoices.map do |invoice|
      invoice_date = invoice.created_at.to_s
      if invoice_date.include?(year.to_s)
        invoice_id = invoice.id
        @parent.invoice_items.find_all_by_invoice_id(invoice_id)
      end
    end.compact.flatten
  end

  def find_invoice_items_per_customer(invoices_per_customer)
    invoices_per_customer.map do |invoice|
      invoice_id = invoice.id
      @parent.invoice_items.invoice_id[invoice_id]
    end.flatten
  end

  def find_item_id_quantities(invoice_items)
    invoice_items.inject(Hash.new(0)) do |hash, invoice_item|
      item_id = invoice_item.item_id
      hash[item_id] = hash[item_id] + invoice_item.quantity.to_i
      hash
    end
  end

  def find_customers_with_unpaid_invoices(unpaid_invoices)
    unpaid_invoices.map do |invoice|
      customer_id = invoice.customer_id
      @parent.customers.find_by_id(customer_id)
    end.uniq
  end

  def find_invoice_items_by_invoices(paid_invoices)
    paid_invoices.map do |invoice|
      invoice_id = invoice.id
      @parent.invoice_items.find_all_by_invoice_id(invoice_id)
    end
  end

  def find_revenue_by_invoice(invoice_items_by_invoices)
    invoice_items_by_invoices.map do |invoice_items|
      invoice_items.inject(0) do |sum, invoice_item|
        sum + (invoice_item.quantity.to_i * invoice_item.unit_price_to_dollars)
      end
    end.flatten
  end

  def find_quantity_by_invoice(invoice_items_by_invoices)
    invoice_items_by_invoices.map do |invoice_items|
      invoice_items.inject(0) do |sum, invoice_item|
        sum + invoice_item.quantity.to_i
      end
    end.flatten
  end

  def find_invoice_of_max_value(revenue_by_invoice, paid_invoices)
    max_revenue = revenue_by_invoice.max
    max_revenue_index = revenue_by_invoice.index(max_revenue)
    paid_invoices[max_revenue_index]
  end

  def find_one_time_buyers_invoices
    one_time_buyers.map do |customer|
      customer_id = customer.id
      invoice = @parent.invoices.find_all_by_customer_id(customer_id)
      invoice_id = invoice.first.id
      @parent.invoice_items.find_all_by_invoice_id(invoice_id)
    end.flatten
  end

  def create_item_quantities(one_time_buyers_invoices)
    one_time_buyers_invoices.inject(Hash.new(0)) do |collector, invoice_item|
      if invoice_paid_in_full?(invoice_item.invoice_id)
        item_id = invoice_item.item_id
        collector[item_id] = collector[item_id] + invoice_item.quantity.to_i
      end
      collector
    end
  end
end
