require_relative 'invoice'
require_relative 'repository_helper'

class InvoiceRepository
  include RepositoryHelper

  attr_reader :id,
              :merchant_id,
              :status,
              :customer_id

  def initialize(invoices)
    @repository = invoices.map { |invoice| Invoice.new(invoice) }
    build_hash_table
  end

  def build_hash_table
    @id = @repository.group_by { |invoice| invoice.id }
    @customer_id = @repository.group_by { |invoice| invoice.customer_id }
    @merchant_id = @repository.group_by { |invoice| invoice.merchant_id }
    @status = @repository.group_by { |invoice| invoice.status }
  end

  def find_by_id(id)
    @repository.find do |invoice|
      invoice.id == id
    end
  end

  def find_all_by_customer_id(customer_id)
    @repository.find_all do |invoice|
      invoice.customer_id == customer_id
    end
  end

  def find_all_by_merchant_id(merchant_id)
    @repository.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end
  end

  def find_all_by_status(status)
    @repository.find_all do |invoice|
      invoice.status == status
    end
  end

  def create(attributes)
    attributes[:id] = last_element_id_plus_one
    @repository << Invoice.new(attributes)
  end

  def update(id, attributes)
    if !find_by_id(id).nil? && attributes.length.positive?
      invoice = find_by_id(id)
      invoice.status = attributes[:status] unless attributes[:status].nil?
      invoice.update_time
    end
  end
end
