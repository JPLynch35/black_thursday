require_relative 'invoice_item'
require_relative 'repository_helper'

class InvoiceItemRepository
  include RepositoryHelper

  attr_reader :quantity,
              :invoice_id

  def initialize(invoice_items)
    @repository = invoice_items.map { |invoice_item| InvoiceItem.new(invoice_item) }
    build_hash_table
  end

  def build_hash_table
    @invoice_id = @repository.group_by { |invoice_item| invoice_item.invoice_id }
    @quantity = @repository.group_by { |invoice_item| invoice_item.quantity }
  end

  def find_by_id(id)
    @repository.find do |invoice_item|
      invoice_item.id == id
    end
  end

  def find_all_by_item_id(item_id)
    @repository.find_all do |invoice_item|
      invoice_item.item_id == item_id
    end
  end

  def find_all_by_invoice_id(invoice_id)
    @repository.find_all do |invoice_item|
      invoice_item.invoice_id == invoice_id
    end
  end

  def create(attributes)
    attributes[:id] = last_element_id_plus_one
    @repository << InvoiceItem.new(attributes)
  end

  def update(id, attributes)
    if !find_by_id(id).nil? && attributes.length.positive?
      invoice_item = find_by_id(id)
      invoice_item.quantity = attributes[:quantity] unless attributes[:quantity].nil?
      invoice_item.unit_price = attributes[:unit_price] unless attributes[:unit_price].nil?
      invoice_item.update_time
    end
  end
end
