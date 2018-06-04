require_relative 'transaction'
require_relative 'repository_helper'

class TransactionRepository
  include RepositoryHelper

  attr_reader :result

  def initialize(transactions)
    @repository = transactions.map { |transaction| Transaction.new(transaction) }
    build_hash_table
  end

  def build_hash_table
    @result = @repository.group_by { |transaction| transaction.result }
  end

  def find_by_id(id)
    @repository.find do |transaction|
      id == transaction.id
    end
  end

  def find_all_by_invoice_id(invoice_id)
    @repository.find_all do |transaction|
      invoice_id == transaction.invoice_id
    end
  end

  def find_all_by_credit_card_number(credit_card_number)
    @repository.find_all do |transaction|
      credit_card_number == transaction.credit_card_number
    end
  end

  def find_all_by_result(result)
    @repository.find_all do |transaction|
      result == transaction.result
    end
  end

  def create(attributes)
    attributes[:id] = last_element_id_plus_one
    @repository << Transaction.new(attributes)
  end

  def update(id, attributes)
    if !find_by_id(id).nil? && attributes.length.positive?
      transaction = find_by_id(id)
      transaction.credit_card_number = attributes[:credit_card_number] unless attributes[:credit_card_number].nil?
      transaction.credit_card_expiration_date = attributes[:credit_card_expiration_date] unless attributes[:credit_card_expiration_date].nil?
      transaction.result = attributes[:result] unless attributes[:result].nil?
      transaction.update_time
    end
  end
end
