class AddBankAccountUriToBalancedContributors < ActiveRecord::Migration
  def change
    add_column :balanced_contributors, :bank_account_uri, :string
  end
end
