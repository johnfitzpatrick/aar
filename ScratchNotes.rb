

Local location
/Users/johnfitzpatrick/Documents/Scratch/learnchefjune14/chef-repo

Cut/pastes
vagrant up
knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node1

knife bootstrap localhost --sudo -x vagrant -P vagrant --ssh-port 2222 -N node2 -r recipe[aar]

knife node run_list set node7 'recipe[aar]'

knife bootstrap uvo1n2g0am70waokpwk.vm.cld.sr --sudo -x opscode -P opscode -N node1 -r recipe[aar]

mysql -u root -e "DROP DATABASE AARdb"



