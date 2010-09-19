require 'spec_helper'

module Recurly
  describe Charge do
    # version accounts based on this current files modification dates
    let(:timestamp) { File.mtime(__FILE__).to_i }

    describe "create a charge" do
      around(:each){|e| VCR.use_cassette('charge/create', &e)}

      let(:account) { Factory.create_account_with_billing_info("#{timestamp}-charge-create") }

      before(:each) do
        charge = Factory.create_charge account.account_code,
                                        :amount => 2.50,
                                        :description => "virtual cow maintence fee"

        @charge = Charge.lookup(account.account_code, charge.id)
      end

      it "should save successfully" do
        @charge.created_at.should_not be_nil
      end

      it "should set the amount" do
        @charge.amount_in_cents.should == 250
      end

      it "should set the description" do
        @charge.description.should == "virtual cow maintence fee"
      end
    end

    describe "list charges for an account" do
      around(:each){|e| VCR.use_cassette('charge/list', &e)}

      let(:account) { Factory.create_account("#{timestamp}-charge-list") }
      before(:each) do
        Factory.create_charge(account.account_code)
        Factory.create_charge(account.account_code)
        Factory.create_charge(account.account_code)

        @charges = Charge.list(account.account_code)
      end

      it "should return all the transactions" do
        @charges.length.should == 3
      end
    end

    describe "lookup a charge" do
      around(:each){|e| VCR.use_cassette('charge/lookup', &e)}

      let(:account) { Factory.create_account("#{timestamp}-charge-lookup") }

      before(:each) do
        charge = Factory.create_charge account.account_code,
                                        :amount => 13.15,
                                        :description => "inconvenience fee"

        @charge = Charge.lookup(account.account_code, charge.id)
      end

      it "should return the correct amount" do
        @charge.amount_in_cents.should == 1315
      end

      it "should return the correct description" do
        @charge.description.should == "inconvenience fee"
      end
    end
  end
end