#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
INPUT=$1

if [[ -z $INPUT ]]
then
  echo "Please provide an element as an argument."
else
  # if input is not a number
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    # if input length is greater than 2, it's a name, otherwise it's a symbol
    LENGTH=$(echo -n "$INPUT" | wc -m)
    if [[ $LENGTH -gt 2 ]]
    then
      # get data by full name
      DATA=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types ON properties.type_id = types.type_id WHERE name='$INPUT'")
    else
      # get data by symbol
      DATA=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types ON properties.type_id = types.type_id WHERE symbol='$INPUT'")
    fi
  else
    # get data by atomic number
    DATA=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types ON properties.type_id = types.type_id WHERE atomic_number=$INPUT")
  fi

  # check if data is found
  if [[ -z $DATA ]]
  then
    echo "I could not find that element in the database."
  else
    # output the result
    echo "$DATA" | while read NUMBER BAR SYMBOL BAR NAME BAR MASS BAR MELTING BAR BOILING BAR TYPE
    do
      echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi

