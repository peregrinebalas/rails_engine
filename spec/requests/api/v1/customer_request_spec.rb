require 'rails_helper'

describe 'Customers API' do
  it 'sends a list of all customers' do
    customers = create_list(:customer, 3)

    get '/api/v1/customers'

    expect(response).to be_successful

    items = JSON.parse(response.body)

    expect(items.count).to eq(3)
  end

  it 'sends a single customer by id' do
    id = create(:customer).id

    get "/api/v1/customers/#{id}"

    customer = JSON.parse(response.body)

    expect(response).to be_successful
    expect(customer["id"]).to eq(id)
  end

  it 'sends a customer by finding id' do
    customer = create(:customer)

    get "/api/v1/customers/find?id=#{customer.id}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json["id"]).to eq(customer.id)
  end

  it 'sends a customer by finding first name' do
    customer = create(:customer)

    get "/api/v1/customers/find?first_name=#{customer.first_name}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json["first_name"]).to eq(customer.first_name)
  end

  it 'sends a customer by finding last name' do
    customer = create(:customer)

    get "/api/v1/customers/find?last_name=#{customer.last_name}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json["last_name"]).to eq(customer.last_name)
  end

  it 'sends a customer by finding created at' do
    customer = create(:customer)

    get "/api/v1/customers/find?created_at=#{customer.created_at}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json["created_at"]).to eq('2012-03-27T14:54:09.000Z')
  end

  it 'sends a customer by finding updated at' do
    customer = create(:customer)

    get "/api/v1/customers/find?updated_at=#{customer.updated_at}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json["updated_at"]).to eq('2012-03-27T14:54:09.000Z')
  end

  it 'sends all customers by finder id' do
    customers = create_list(:customer, 3)

    get "/api/v1/customers/find_all?id=#{customers[0].id}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json.count).to eq(1)
    expect(json[0]["id"]).to eq(customers[0].id)
  end

  it 'sends all customers by finder first name' do
    bobs = create_list(:customer, 3, first_name: "Bob")
    customers = create_list(:customer, 3)

    get "/api/v1/customers/find_all?first_name=#{bobs[0].first_name}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json.count).to eq(3)
    json.each do |customer|
      expect(customer["first_name"]).to eq("Bob")
    end
  end

  it 'sends all customers by finder last name' do
    smiths = create_list(:customer, 3, last_name: "Smith")
    customers = create_list(:customer, 3)

    get "/api/v1/customers/find_all?last_name=#{smiths[0].last_name}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json.count).to eq(3)
    json.each do |customer|
      expect(customer["last_name"]).to eq("Smith")
    end
  end

  it 'sends all customers by finder created at' do
    customers = create_list(:customer, 3)
    later_customer = create(:customer, created_at: "2012-03-27 16:54:09 UTC")

    get "/api/v1/customers/find_all?created_at=#{customers[0].created_at}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json.count).to eq(3)
    json.each do |customer|
      expect(customer["created_at"]).to eq('2012-03-27T14:54:09.000Z')
    end
  end

  it 'sends all customers by finder updated at' do
    customers = create_list(:customer, 3)
    later_customer = create(:customer, updated_at: "2012-03-27 16:54:09 UTC")

    get "/api/v1/customers/find_all?updated_at=#{customers[0].updated_at}"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json.count).to eq(3)
    json.each do |customer|
      expect(customer["created_at"]).to eq('2012-03-27T14:54:09.000Z')
    end
  end

  it 'returns a random resource' do
    customers = create_list(:customer, 3)

    get "/api/v1/customers/random.json"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    first_names = customers.map { |c| c.first_name }
    expect(first_names).to include(json["first_name"])
  end

  it 'returns all associated invoices' do
    customer = create(:customer)
    other_customer = create(:customer)
    merchant = create(:merchant)
    invoices = create_list(:invoice, 3, customer: customer, merchant: merchant)
    other_invoices = create_list(:invoice, 3, customer: other_customer, merchant: merchant)

    get "/api/v1/customers/#{customer.id}/invoices"

    json = JSON.parse(response.body)
    expect(response).to be_successful
    expect(json.count).to eq(3)
    invoice_ids = invoices.map { |i| i.id }
    json.each do |invoice|
      expect(invoice_ids).to include(invoice["id"])
    end
  end

  xit 'returns all associated transactions' do
    customer = create(:customer)
    other_customer = create(:customer)
    merchant = create(:merchant)
    invoices = create_list(:invoice, 3, customer: customer)
    invoice_1_transactions = create_list(:transaction, 3, invoice: invoices[0])
    invoice_2_transactions = create_list(:transaction, 3, invoice: invoices[1])
    invoice_3_transactions = create_list(:transaction, 3, invoice: invoices[2])
    transactions = []
    transactions << invoice_1_transactions
    transactions << invoice_2_transactions
    transactions << invoice_3_transactions
    transactions.flatten
    other_invoices = create_list(:invoice, 3, customer: other_customer)
    other_invoice_transactions = create_list(:transaction, 3, invoice: other_invoices[0])

    get "/api/v1/customers/#{customer.id}/transactions"

    json = JSON.parse(response.body)
    expect(response).to be_successful
    expect(json.count).to eq(9)
    transaction_ids = transactions.map { |i| i.id }
    json.each do |invoice|
      expect(transaction_ids).to include(invoice["id"])
    end
  end

  it 'returns the favorite merchant for the customer' do
    customer = create(:customer)

    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    merchant_3 = create(:merchant)

    invoices_1 = create_list(:invoice, 3, customer: customer, merchant: merchant_1)
    invoices_2 = create_list(:invoice, 2, customer: customer, merchant: merchant_2)
    transaction_1 = create(:transaction, invoice: invoices_1[0])
    transaction_2 = create(:transaction, invoice: invoices_1[1])
    transaction_3 = create(:transaction,  invoice: invoices_1[2])
    transactions_4_5_6 = create_list(:transaction, 3, invoice: invoices_2[0])
    transactions_5_6_7 = create_list(:transaction, 3, invoice: invoices_2[1])

    get "/api/v1/customers/#{customer.id}/favorite_merchant"

    json = JSON.parse(response.body)

    expect(response).to be_successful
    expect(json["id"]).to eq(merchant_2.id)
  end

end
