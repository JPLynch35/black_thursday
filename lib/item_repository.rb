require_relative 'item'
require_relative 'repository_helper'

class ItemRepository
  include RepositoryHelper

  attr_reader :merchant_id,
              :unit_price

  def initialize(items, parent)
    @repository = items.map { |item| Item.new(item, self) }
    @parent = parent
    build_hash_table
  end

  def build_hash_table
    @id = @repository.group_by { |item| item.id }
    @name = @repository.group_by { |item| item.name }
    @description = @repository.group_by { |item| item.description }
    @unit_price = @repository.group_by { |item| item.unit_price }
    @merchant_id = @repository.group_by { |item| item.merchant_id }
    @created_at = @repository.group_by { |item| item.created_at }
    @updated_at = @repository.group_by { |item| item.updated_at }
  end

  def find_by_id(id)
    @repository.find do |item|
      id == item.id
    end
  end

  def find_by_name(name)
    @repository.find do |item|
      item.name.casecmp(name).zero?
    end
  end

  def find_all_with_description(description)
    @repository.find_all do |item|
      item.description.casecmp(description).zero?
    end
  end

  def find_all_by_price(price)
    @repository.find_all do |item|
      item.unit_price_to_dollars == price.to_f
    end
  end

  def find_all_by_price_in_range(range)
    @repository.find_all do |item|
      item.unit_price_to_dollars.between?(range.first, range.last)
    end
  end

  def find_all_by_merchant_id(merchant_id)
    @repository.find_all do |item|
      item.merchant_id.to_i == merchant_id
    end
  end

  def create(attributes)
    new_last_merchant_id = last_element_id_plus_one
    attributes[:id] = new_last_merchant_id
    @repository << Item.new(attributes, self)
  end

  def update(id, attributes)
    if !find_by_id(id).nil? && attributes.length.positive?
      item = find_by_id(id)
      item.name = attributes[:name] unless attributes[:name].nil?
      item.description = attributes[:description] unless attributes[:description].nil?
      item.unit_price = BigDecimal(attributes[:unit_price]) unless attributes[:unit_price].nil?
      item.unit_price_to_dollars = (attributes[:unit_price]).to_f unless attributes[:unit_price].nil?
      item.update_time
    end
  end
end
