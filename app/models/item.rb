class Item < ApplicationRecord
  enum kind: { expenses: 1, income: 2 }
  validates :amount, presence: true
  validates :tags_id, presence: true
  validates :happen_at, presence: true
  validates :kind, presence: true

  belongs_to :user

  validate :check_tags_id_belong_to_user

  def check_tags_id_belong_to_user
    all_tags_ids = Tag.where(user_id: self.user_id).map(&:id)
    if self.tags_id & all_tags_ids != self.tags_id
      self.errors.add :tags_id, '标签不属于当前用户'
    end
  end
end
