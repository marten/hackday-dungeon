class RangedWeapon
  include JSON::Serializable
end

class Bow < RangedWeapon
  getter damage = 10
end
