class MeleeWeapon
  include JSON::Serializable
end

class Sword < MeleeWeapon
  getter damage = 5
end
