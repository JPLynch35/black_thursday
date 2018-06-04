require_relative 'merchant'
require_relative 'repository_helper'

class MerchantRepository
  include RepositoryHelper

  attr_reader :id

  def initialize(merchants)
    @repository = merchants.map { |merchant| Merchant.new(merchant) }
    build_hash_table
  end

  def build_hash_table
    @id = @repository.group_by { |merchant| merchant.id }
  end

  def find_by_id(id)
    @repository.find do |merchant|
      id == merchant.id
    end
  end

  def find_by_name(name)
    @repository.find do |merchant|
      merchant.name.casecmp(name).zero?
    end
  end

  def find_all_by_name(name)
    @repository.find_all do |merchant|
      merchant.name.downcase.include?(name.downcase)
    end
  end

  def create(attributes)
    attributes[:id] = last_element_id_plus_one
    @repository << Merchant.new(attributes)
  end

  def update(id, attributes)
    if !find_by_id(id).nil? && attributes.length.positive?
      merchant = find_by_id(id)
      merchant.name = attributes[:name] unless attributes[:name].nil?
      merchant.update_time
    end
  end
end
