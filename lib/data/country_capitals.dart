// Country capitals with their coordinates (latitude, longitude)
// Used for calculating distance between guessed country and correct country

class CountryCapital {
  final String country;
  final String capital;
  final double latitude;
  final double longitude;

  const CountryCapital({
    required this.country,
    required this.capital,
    required this.latitude,
    required this.longitude,
  });
}

const List<CountryCapital> countryCapitals = [
  CountryCapital(
    country: 'Afghanistan',
    capital: 'Kabul',
    latitude: 34.5553,
    longitude: 69.2075,
  ),
  CountryCapital(
    country: 'Albania',
    capital: 'Tirana',
    latitude: 41.3275,
    longitude: 19.8187,
  ),
  CountryCapital(
    country: 'Algeria',
    capital: 'Algiers',
    latitude: 36.7538,
    longitude: 3.0588,
  ),
  CountryCapital(
    country: 'Andorra',
    capital: 'Andorra la Vella',
    latitude: 42.5063,
    longitude: 1.5218,
  ),
  CountryCapital(
    country: 'Angola',
    capital: 'Luanda',
    latitude: -8.8383,
    longitude: 13.2344,
  ),
  CountryCapital(
    country: 'Antigua and Barbuda',
    capital: 'Saint John\'s',
    latitude: 17.1899,
    longitude: -61.8449,
  ),
  CountryCapital(
    country: 'Argentina',
    capital: 'Buenos Aires',
    latitude: -34.6037,
    longitude: -58.3816,
  ),
  CountryCapital(
    country: 'Armenia',
    capital: 'Yerevan',
    latitude: 40.1792,
    longitude: 44.5086,
  ),
  CountryCapital(
    country: 'Australia',
    capital: 'Canberra',
    latitude: -35.2809,
    longitude: 149.1300,
  ),
  CountryCapital(
    country: 'Austria',
    capital: 'Vienna',
    latitude: 48.2082,
    longitude: 16.3738,
  ),
  CountryCapital(
    country: 'Azerbaijan',
    capital: 'Baku',
    latitude: 40.3856,
    longitude: 49.8831,
  ),
  CountryCapital(
    country: 'Bahamas',
    capital: 'Nassau',
    latitude: 25.0343,
    longitude: -77.3963,
  ),
  CountryCapital(
    country: 'Bahrain',
    capital: 'Manama',
    latitude: 26.1667,
    longitude: 50.5567,
  ),
  CountryCapital(
    country: 'Bangladesh',
    capital: 'Dhaka',
    latitude: 23.8103,
    longitude: 90.4125,
  ),
  CountryCapital(
    country: 'Barbados',
    capital: 'Bridgetown',
    latitude: 13.1939,
    longitude: -59.5432,
  ),
  CountryCapital(
    country: 'Belarus',
    capital: 'Minsk',
    latitude: 53.9045,
    longitude: 27.5615,
  ),
  CountryCapital(
    country: 'Belgium',
    capital: 'Brussels',
    latitude: 50.8503,
    longitude: 4.3517,
  ),
  CountryCapital(
    country: 'Belize',
    capital: 'Belmopan',
    latitude: 17.2505,
    longitude: -88.7589,
  ),
  CountryCapital(
    country: 'Benin',
    capital: 'Porto-Novo',
    latitude: 6.4969,
    longitude: 2.6289,
  ),
  CountryCapital(
    country: 'Bhutan',
    capital: 'Thimphu',
    latitude: 27.5142,
    longitude: 89.6408,
  ),
  CountryCapital(
    country: 'Bolivia',
    capital: 'La Paz',
    latitude: -16.5000,
    longitude: -68.1500,
  ),
  CountryCapital(
    country: 'Bosnia and Herzegovina',
    capital: 'Sarajevo',
    latitude: 43.8564,
    longitude: 18.4131,
  ),
  CountryCapital(
    country: 'Botswana',
    capital: 'Gaborone',
    latitude: -24.6282,
    longitude: 25.9165,
  ),
  CountryCapital(
    country: 'Brazil',
    capital: 'Brasília',
    latitude: -15.7942,
    longitude: -47.8822,
  ),
  CountryCapital(
    country: 'Brunei',
    capital: 'Bandar Seri Begawan',
    latitude: 4.8830,
    longitude: 114.9430,
  ),
  CountryCapital(
    country: 'Bulgaria',
    capital: 'Sofia',
    latitude: 42.6977,
    longitude: 23.3219,
  ),
  CountryCapital(
    country: 'Burkina Faso',
    capital: 'Ouagadougou',
    latitude: 12.3714,
    longitude: -1.5197,
  ),
  CountryCapital(
    country: 'Burundi',
    capital: 'Gitega',
    latitude: -3.4289,
    longitude: 29.9412,
  ),
  CountryCapital(
    country: 'Cabo Verde',
    capital: 'Praia',
    latitude: 14.9333,
    longitude: -23.6166,
  ),
  CountryCapital(
    country: 'Cambodia',
    capital: 'Phnom Penh',
    latitude: 11.5564,
    longitude: 104.9282,
  ),
  CountryCapital(
    country: 'Cameroon',
    capital: 'Yaoundé',
    latitude: 3.8480,
    longitude: 11.5021,
  ),
  CountryCapital(
    country: 'Canada',
    capital: 'Ottawa',
    latitude: 45.4215,
    longitude: -75.6972,
  ),
  CountryCapital(
    country: 'Central African Republic',
    capital: 'Bangui',
    latitude: 4.3826,
    longitude: 18.5579,
  ),
  CountryCapital(
    country: 'Chad',
    capital: 'N\'Djamena',
    latitude: 12.1348,
    longitude: 15.0557,
  ),
  CountryCapital(
    country: 'Chile',
    capital: 'Santiago',
    latitude: -33.4489,
    longitude: -70.6693,
  ),
  CountryCapital(
    country: 'China',
    capital: 'Beijing',
    latitude: 39.9042,
    longitude: 116.4074,
  ),
  CountryCapital(
    country: 'Colombia',
    capital: 'Bogotá',
    latitude: 4.7110,
    longitude: -74.0721,
  ),
  CountryCapital(
    country: 'Comoros',
    capital: 'Moroni',
    latitude: -11.6869,
    longitude: 43.3333,
  ),
  CountryCapital(
    country: 'Congo, Democratic Republic of the',
    capital: 'Kinshasa',
    latitude: -4.3276,
    longitude: 15.3136,
  ),
  CountryCapital(
    country: 'Congo, Republic of the',
    capital: 'Brazzaville',
    latitude: -4.2591,
    longitude: 15.2429,
  ),
  CountryCapital(
    country: 'Costa Rica',
    capital: 'San José',
    latitude: 9.9281,
    longitude: -84.0907,
  ),
  CountryCapital(
    country: 'Cote d\'Ivoire',
    capital: 'Yamoussoukro',
    latitude: 6.8270,
    longitude: -5.2893,
  ),
  CountryCapital(
    country: 'Croatia',
    capital: 'Zagreb',
    latitude: 45.8150,
    longitude: 15.9819,
  ),
  CountryCapital(
    country: 'Cuba',
    capital: 'Havana',
    latitude: 23.1291,
    longitude: -82.3794,
  ),
  CountryCapital(
    country: 'Cyprus',
    capital: 'Nicosia',
    latitude: 35.1264,
    longitude: 33.4299,
  ),
  CountryCapital(
    country: 'Czech Republic',
    capital: 'Prague',
    latitude: 50.0755,
    longitude: 14.4378,
  ),
  CountryCapital(
    country: 'Denmark',
    capital: 'Copenhagen',
    latitude: 55.6761,
    longitude: 12.5683,
  ),
  CountryCapital(
    country: 'Djibouti',
    capital: 'Djibouti',
    latitude: 11.5897,
    longitude: 42.5604,
  ),
  CountryCapital(
    country: 'Dominica',
    capital: 'Roseau',
    latitude: 15.3008,
    longitude: -61.3881,
  ),
  CountryCapital(
    country: 'Dominican Republic',
    capital: 'Santo Domingo',
    latitude: 18.4861,
    longitude: -69.9312,
  ),
  CountryCapital(
    country: 'East Timor',
    capital: 'Dili',
    latitude: -8.5570,
    longitude: 125.5603,
  ),
  CountryCapital(
    country: 'Ecuador',
    capital: 'Quito',
    latitude: -0.2298,
    longitude: -78.5248,
  ),
  CountryCapital(
    country: 'Egypt',
    capital: 'Cairo',
    latitude: 30.0444,
    longitude: 31.2357,
  ),
  CountryCapital(
    country: 'El Salvador',
    capital: 'San Salvador',
    latitude: 13.6929,
    longitude: -89.2182,
  ),
  CountryCapital(
    country: 'Equatorial Guinea',
    capital: 'Malabo',
    latitude: 3.7521,
    longitude: 8.7737,
  ),
  CountryCapital(
    country: 'Eritrea',
    capital: 'Asmara',
    latitude: 15.3387,
    longitude: 38.9155,
  ),
  CountryCapital(
    country: 'Estonia',
    capital: 'Tallinn',
    latitude: 59.4370,
    longitude: 24.7536,
  ),
  CountryCapital(
    country: 'Ethiopia',
    capital: 'Addis Ababa',
    latitude: 9.0320,
    longitude: 38.7469,
  ),
  CountryCapital(
    country: 'Fiji',
    capital: 'Suva',
    latitude: -18.1256,
    longitude: 178.4501,
  ),
  CountryCapital(
    country: 'Finland',
    capital: 'Helsinki',
    latitude: 60.1699,
    longitude: 24.9384,
  ),
  CountryCapital(
    country: 'France',
    capital: 'Paris',
    latitude: 48.8566,
    longitude: 2.3522,
  ),
  CountryCapital(
    country: 'Gabon',
    capital: 'Libreville',
    latitude: 0.4162,
    longitude: 9.4673,
  ),
  CountryCapital(
    country: 'Gambia',
    capital: 'Banjul',
    latitude: 13.4549,
    longitude: -16.5790,
  ),
  CountryCapital(
    country: 'Georgia',
    capital: 'Tbilisi',
    latitude: 41.7151,
    longitude: 44.8271,
  ),
  CountryCapital(
    country: 'Germany',
    capital: 'Berlin',
    latitude: 52.5200,
    longitude: 13.4050,
  ),
  CountryCapital(
    country: 'Ghana',
    capital: 'Accra',
    latitude: 5.6037,
    longitude: -0.1870,
  ),
  CountryCapital(
    country: 'Greece',
    capital: 'Athens',
    latitude: 37.9838,
    longitude: 23.7275,
  ),
  CountryCapital(
    country: 'Grenada',
    capital: 'St. George\'s',
    latitude: 12.0564,
    longitude: -61.7480,
  ),
  CountryCapital(
    country: 'Guatemala',
    capital: 'Guatemala City',
    latitude: 14.6343,
    longitude: -90.5069,
  ),
  CountryCapital(
    country: 'Guinea',
    capital: 'Conakry',
    latitude: 9.6412,
    longitude: -13.5784,
  ),
  CountryCapital(
    country: 'Guinea-Bissau',
    capital: 'Bissau',
    latitude: 11.8037,
    longitude: -15.5942,
  ),
  CountryCapital(
    country: 'Guyana',
    capital: 'Georgetown',
    latitude: 6.8016,
    longitude: -58.1551,
  ),
  CountryCapital(
    country: 'Haiti',
    capital: 'Port-au-Prince',
    latitude: 18.9712,
    longitude: -72.2852,
  ),
  CountryCapital(
    country: 'Honduras',
    capital: 'Tegucigalpa',
    latitude: 14.0723,
    longitude: -87.1921,
  ),
  CountryCapital(
    country: 'Hungary',
    capital: 'Budapest',
    latitude: 47.4979,
    longitude: 19.0402,
  ),
  CountryCapital(
    country: 'Iceland',
    capital: 'Reykjavik',
    latitude: 64.1466,
    longitude: -21.9426,
  ),
  CountryCapital(
    country: 'India',
    capital: 'New Delhi',
    latitude: 28.7041,
    longitude: 77.1025,
  ),
  CountryCapital(
    country: 'Indonesia',
    capital: 'Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
  ),
  CountryCapital(
    country: 'Iran',
    capital: 'Tehran',
    latitude: 35.6892,
    longitude: 51.3890,
  ),
  CountryCapital(
    country: 'Iraq',
    capital: 'Baghdad',
    latitude: 33.3157,
    longitude: 44.3661,
  ),
  CountryCapital(
    country: 'Ireland',
    capital: 'Dublin',
    latitude: 53.3498,
    longitude: -6.2603,
  ),
  CountryCapital(
    country: 'Israel',
    capital: 'Jerusalem',
    latitude: 31.7683,
    longitude: 35.2137,
  ),
  CountryCapital(
    country: 'Italy',
    capital: 'Rome',
    latitude: 41.9028,
    longitude: 12.4964,
  ),
  CountryCapital(
    country: 'Jamaica',
    capital: 'Kingston',
    latitude: 17.9757,
    longitude: -76.8083,
  ),
  CountryCapital(
    country: 'Japan',
    capital: 'Tokyo',
    latitude: 35.6762,
    longitude: 139.6503,
  ),
  CountryCapital(
    country: 'Jordan',
    capital: 'Amman',
    latitude: 31.9454,
    longitude: 35.9284,
  ),
  CountryCapital(
    country: 'Kazakhstan',
    capital: 'Nur-Sultan',
    latitude: 51.1694,
    longitude: 71.4491,
  ),
  CountryCapital(
    country: 'Kenya',
    capital: 'Nairobi',
    latitude: -1.2865,
    longitude: 36.8172,
  ),
  CountryCapital(
    country: 'Kiribati',
    capital: 'Tarawa',
    latitude: 1.3521,
    longitude: 173.0066,
  ),
  CountryCapital(
    country: 'Korea, North',
    capital: 'Pyongyang',
    latitude: 39.0196,
    longitude: 125.7453,
  ),
  CountryCapital(
    country: 'Korea, South',
    capital: 'Seoul',
    latitude: 37.5665,
    longitude: 126.9780,
  ),
  CountryCapital(
    country: 'Kuwait',
    capital: 'Kuwait City',
    latitude: 29.3759,
    longitude: 47.9774,
  ),
  CountryCapital(
    country: 'Kyrgyzstan',
    capital: 'Bishkek',
    latitude: 42.8746,
    longitude: 74.5698,
  ),
  CountryCapital(
    country: 'Laos',
    capital: 'Vientiane',
    latitude: 17.9757,
    longitude: 102.6331,
  ),
  CountryCapital(
    country: 'Latvia',
    capital: 'Riga',
    latitude: 56.9496,
    longitude: 24.1052,
  ),
  CountryCapital(
    country: 'Lebanon',
    capital: 'Beirut',
    latitude: 33.8886,
    longitude: 35.4955,
  ),
  CountryCapital(
    country: 'Lesotho',
    capital: 'Maseru',
    latitude: -29.6100,
    longitude: 25.9655,
  ),
  CountryCapital(
    country: 'Liberia',
    capital: 'Monrovia',
    latitude: 6.3156,
    longitude: -10.8073,
  ),
  CountryCapital(
    country: 'Libya',
    capital: 'Tripoli',
    latitude: 32.8872,
    longitude: 13.1913,
  ),
  CountryCapital(
    country: 'Liechtenstein',
    capital: 'Vaduz',
    latitude: 47.1411,
    longitude: 9.5209,
  ),
  CountryCapital(
    country: 'Lithuania',
    capital: 'Vilnius',
    latitude: 54.6872,
    longitude: 25.2797,
  ),
  CountryCapital(
    country: 'Luxembourg',
    capital: 'Luxembourg',
    latitude: 49.6116,
    longitude: 6.1319,
  ),
  CountryCapital(
    country: 'Madagascar',
    capital: 'Antananarivo',
    latitude: -18.8792,
    longitude: 47.5079,
  ),
  CountryCapital(
    country: 'Malawi',
    capital: 'Lilongwe',
    latitude: -13.9626,
    longitude: 33.7741,
  ),
  CountryCapital(
    country: 'Malaysia',
    capital: 'Kuala Lumpur',
    latitude: 3.1390,
    longitude: 101.6869,
  ),
  CountryCapital(
    country: 'Maldives',
    capital: 'Malé',
    latitude: 4.1755,
    longitude: 73.5093,
  ),
  CountryCapital(
    country: 'Mali',
    capital: 'Bamako',
    latitude: 12.6392,
    longitude: -8.0029,
  ),
  CountryCapital(
    country: 'Malta',
    capital: 'Valletta',
    latitude: 35.8989,
    longitude: 14.5146,
  ),
  CountryCapital(
    country: 'Marshall Islands',
    capital: 'Majuro',
    latitude: 7.1315,
    longitude: 171.1845,
  ),
  CountryCapital(
    country: 'Mauritania',
    capital: 'Nouakchott',
    latitude: 18.0735,
    longitude: -15.9582,
  ),
  CountryCapital(
    country: 'Mauritius',
    capital: 'Port Louis',
    latitude: -20.1609,
    longitude: 57.5012,
  ),
  CountryCapital(
    country: 'Mexico',
    capital: 'Mexico City',
    latitude: 19.4326,
    longitude: -99.1332,
  ),
  CountryCapital(
    country: 'Micronesia',
    capital: 'Palikir',
    latitude: 6.9150,
    longitude: 158.1610,
  ),
  CountryCapital(
    country: 'Moldova',
    capital: 'Chișinău',
    latitude: 47.8184,
    longitude: 28.3731,
  ),
  CountryCapital(
    country: 'Monaco',
    capital: 'Monaco',
    latitude: 43.7384,
    longitude: 7.4246,
  ),
  CountryCapital(
    country: 'Mongolia',
    capital: 'Ulaanbaatar',
    latitude: 47.9199,
    longitude: 106.8537,
  ),
  CountryCapital(
    country: 'Montenegro',
    capital: 'Podgorica',
    latitude: 42.4304,
    longitude: 19.2594,
  ),
  CountryCapital(
    country: 'Morocco',
    capital: 'Rabat',
    latitude: 34.0209,
    longitude: -6.8416,
  ),
  CountryCapital(
    country: 'Mozambique',
    capital: 'Maputo',
    latitude: -23.8653,
    longitude: 35.3519,
  ),
  CountryCapital(
    country: 'Myanmar',
    capital: 'Naypyidaw',
    latitude: 19.7633,
    longitude: 96.0836,
  ),
  CountryCapital(
    country: 'Namibia',
    capital: 'Windhoek',
    latitude: -22.5597,
    longitude: 17.0832,
  ),
  CountryCapital(
    country: 'Nauru',
    capital: 'Yaren',
    latitude: -0.5478,
    longitude: 166.9315,
  ),
  CountryCapital(
    country: 'Nepal',
    capital: 'Kathmandu',
    latitude: 27.7172,
    longitude: 85.3240,
  ),
  CountryCapital(
    country: 'Netherlands',
    capital: 'Amsterdam',
    latitude: 52.3676,
    longitude: 4.9041,
  ),
  CountryCapital(
    country: 'New Zealand',
    capital: 'Wellington',
    latitude: -41.2865,
    longitude: 174.7762,
  ),
  CountryCapital(
    country: 'Nicaragua',
    capital: 'Managua',
    latitude: 12.1150,
    longitude: -86.2362,
  ),
  CountryCapital(
    country: 'Niger',
    capital: 'Niamey',
    latitude: 13.5116,
    longitude: 2.1257,
  ),
  CountryCapital(
    country: 'Nigeria',
    capital: 'Abuja',
    latitude: 9.0765,
    longitude: 7.3986,
  ),
  CountryCapital(
    country: 'Norway',
    capital: 'Oslo',
    latitude: 59.9139,
    longitude: 10.7522,
  ),
  CountryCapital(
    country: 'Oman',
    capital: 'Muscat',
    latitude: 23.6100,
    longitude: 58.5400,
  ),
  CountryCapital(
    country: 'Pakistan',
    capital: 'Islamabad',
    latitude: 33.6844,
    longitude: 73.0479,
  ),
  CountryCapital(
    country: 'Palau',
    capital: 'Ngerulmud',
    latitude: 7.3149,
    longitude: 134.4817,
  ),
  CountryCapital(
    country: 'Palestine',
    capital: 'Ramallah',
    latitude: 31.9454,
    longitude: 35.2075,
  ),
  CountryCapital(
    country: 'Panama',
    capital: 'Panama City',
    latitude: 8.9824,
    longitude: -79.5199,
  ),
  CountryCapital(
    country: 'Papua New Guinea',
    capital: 'Port Moresby',
    latitude: -9.4438,
    longitude: 147.1803,
  ),
  CountryCapital(
    country: 'Paraguay',
    capital: 'Asunción',
    latitude: -25.2637,
    longitude: -57.5759,
  ),
  CountryCapital(
    country: 'Peru',
    capital: 'Lima',
    latitude: -12.0464,
    longitude: -77.0428,
  ),
  CountryCapital(
    country: 'Philippines',
    capital: 'Manila',
    latitude: 14.5995,
    longitude: 120.9842,
  ),
  CountryCapital(
    country: 'Poland',
    capital: 'Warsaw',
    latitude: 52.2297,
    longitude: 21.0122,
  ),
  CountryCapital(
    country: 'Portugal',
    capital: 'Lisbon',
    latitude: 38.7223,
    longitude: -9.1393,
  ),
  CountryCapital(
    country: 'Qatar',
    capital: 'Doha',
    latitude: 25.2854,
    longitude: 51.5310,
  ),
  CountryCapital(
    country: 'Romania',
    capital: 'Bucharest',
    latitude: 44.4268,
    longitude: 26.1025,
  ),
  CountryCapital(
    country: 'Russia',
    capital: 'Moscow',
    latitude: 55.7558,
    longitude: 37.6173,
  ),
  CountryCapital(
    country: 'Rwanda',
    capital: 'Kigali',
    latitude: -1.9536,
    longitude: 29.8739,
  ),
  CountryCapital(
    country: 'Saint Kitts and Nevis',
    capital: 'Basseterre',
    latitude: 17.2978,
    longitude: -62.7830,
  ),
  CountryCapital(
    country: 'Saint Lucia',
    capital: 'Castries',
    latitude: 14.0080,
    longitude: -60.9880,
  ),
  CountryCapital(
    country: 'Saint Vincent and the Grenadines',
    capital: 'Kingstown',
    latitude: 13.1559,
    longitude: -61.2248,
  ),
  CountryCapital(
    country: 'Samoa',
    capital: 'Apia',
    latitude: -13.8314,
    longitude: -171.7629,
  ),
  CountryCapital(
    country: 'San Marino',
    capital: 'San Marino',
    latitude: 43.9424,
    longitude: 12.4578,
  ),
  CountryCapital(
    country: 'Sao Tome and Principe',
    capital: 'São Tomé',
    latitude: 0.3365,
    longitude: 6.7273,
  ),
  CountryCapital(
    country: 'Saudi Arabia',
    capital: 'Riyadh',
    latitude: 24.7136,
    longitude: 46.6753,
  ),
  CountryCapital(
    country: 'Senegal',
    capital: 'Dakar',
    latitude: 14.7167,
    longitude: -17.4674,
  ),
  CountryCapital(
    country: 'Serbia',
    capital: 'Belgrade',
    latitude: 44.8176,
    longitude: 20.4612,
  ),
  CountryCapital(
    country: 'Seychelles',
    capital: 'Victoria',
    latitude: -4.6226,
    longitude: 55.4437,
  ),
  CountryCapital(
    country: 'Sierra Leone',
    capital: 'Freetown',
    latitude: 8.4865,
    longitude: -13.2317,
  ),
  CountryCapital(
    country: 'Singapore',
    capital: 'Singapore',
    latitude: 1.3521,
    longitude: 103.8198,
  ),
  CountryCapital(
    country: 'Slovakia',
    capital: 'Bratislava',
    latitude: 48.1486,
    longitude: 17.1077,
  ),
  CountryCapital(
    country: 'Slovenia',
    capital: 'Ljubljana',
    latitude: 46.0569,
    longitude: 14.5058,
  ),
  CountryCapital(
    country: 'Solomon Islands',
    capital: 'Honiara',
    latitude: -9.4280,
    longitude: 159.9789,
  ),
  CountryCapital(
    country: 'Somalia',
    capital: 'Mogadishu',
    latitude: 2.0469,
    longitude: 45.3182,
  ),
  CountryCapital(
    country: 'South Africa',
    capital: 'Pretoria',
    latitude: -25.7461,
    longitude: 28.2293,
  ),
  CountryCapital(
    country: 'South Sudan',
    capital: 'Juba',
    latitude: 4.8517,
    longitude: 31.5825,
  ),
  CountryCapital(
    country: 'Spain',
    capital: 'Madrid',
    latitude: 40.4168,
    longitude: -3.7038,
  ),
  CountryCapital(
    country: 'Sri Lanka',
    capital: 'Colombo',
    latitude: 6.9271,
    longitude: 80.7744,
  ),
  CountryCapital(
    country: 'Sudan',
    capital: 'Khartoum',
    latitude: 15.5007,
    longitude: 32.5599,
  ),
  CountryCapital(
    country: 'Suriname',
    capital: 'Paramaribo',
    latitude: 5.8520,
    longitude: -58.0221,
  ),
  CountryCapital(
    country: 'Swaziland',
    capital: 'Mbabane',
    latitude: -26.4054,
    longitude: 31.1367,
  ),
  CountryCapital(
    country: 'Sweden',
    capital: 'Stockholm',
    latitude: 59.3293,
    longitude: 18.0686,
  ),
  CountryCapital(
    country: 'Switzerland',
    capital: 'Bern',
    latitude: 46.9479,
    longitude: 7.4474,
  ),
  CountryCapital(
    country: 'Syria',
    capital: 'Damascus',
    latitude: 33.5102,
    longitude: 36.2765,
  ),
  CountryCapital(
    country: 'Taiwan',
    capital: 'Taipei',
    latitude: 25.0330,
    longitude: 121.5654,
  ),
  CountryCapital(
    country: 'Tajikistan',
    capital: 'Dushanbe',
    latitude: 38.5598,
    longitude: 68.7738,
  ),
  CountryCapital(
    country: 'Tanzania',
    capital: 'Dar es Salaam',
    latitude: -6.8000,
    longitude: 39.2833,
  ),
  CountryCapital(
    country: 'Thailand',
    capital: 'Bangkok',
    latitude: 13.7563,
    longitude: 100.5018,
  ),
  CountryCapital(
    country: 'Togo',
    capital: 'Lomé',
    latitude: 6.1256,
    longitude: 1.2317,
  ),
  CountryCapital(
    country: 'Tonga',
    capital: 'Nuku\'alofa',
    latitude: -21.1394,
    longitude: -175.2060,
  ),
  CountryCapital(
    country: 'Trinidad and Tobago',
    capital: 'Port of Spain',
    latitude: 10.7691,
    longitude: -61.5289,
  ),
  CountryCapital(
    country: 'Tunisia',
    capital: 'Tunis',
    latitude: 36.8065,
    longitude: 10.1815,
  ),
  CountryCapital(
    country: 'Turkey',
    capital: 'Ankara',
    latitude: 39.9334,
    longitude: 32.8597,
  ),
  CountryCapital(
    country: 'Turkmenistan',
    capital: 'Ashgabat',
    latitude: 37.9601,
    longitude: 58.3261,
  ),
  CountryCapital(
    country: 'Tuvalu',
    capital: 'Funafuti',
    latitude: -8.5211,
    longitude: 179.1982,
  ),
  CountryCapital(
    country: 'Uganda',
    capital: 'Kampala',
    latitude: 0.3476,
    longitude: 32.5825,
  ),
  CountryCapital(
    country: 'Ukraine',
    capital: 'Kyiv',
    latitude: 50.4501,
    longitude: 30.5234,
  ),
  CountryCapital(
    country: 'United Arab Emirates',
    capital: 'Abu Dhabi',
    latitude: 24.4539,
    longitude: 54.3773,
  ),
  CountryCapital(
    country: 'United Kingdom',
    capital: 'London',
    latitude: 51.5074,
    longitude: -0.1278,
  ),
  CountryCapital(
    country: 'United States',
    capital: 'Washington, D.C.',
    latitude: 38.8951,
    longitude: -77.0369,
  ),
  CountryCapital(
    country: 'Uruguay',
    capital: 'Montevideo',
    latitude: -34.9011,
    longitude: -56.1645,
  ),
  CountryCapital(
    country: 'Uzbekistan',
    capital: 'Tashkent',
    latitude: 41.2995,
    longitude: 69.2401,
  ),
  CountryCapital(
    country: 'Vanuatu',
    capital: 'Port Vila',
    latitude: -17.7404,
    longitude: 168.3059,
  ),
  CountryCapital(
    country: 'Vatican City',
    capital: 'Vatican City',
    latitude: 41.9029,
    longitude: 12.4534,
  ),
  CountryCapital(
    country: 'Venezuela',
    capital: 'Caracas',
    latitude: 10.4806,
    longitude: -66.9036,
  ),
  CountryCapital(
    country: 'Vietnam',
    capital: 'Hanoi',
    latitude: 21.0285,
    longitude: 105.8542,
  ),
  CountryCapital(
    country: 'Yemen',
    capital: 'Sana\'a',
    latitude: 15.3694,
    longitude: 48.2163,
  ),
  CountryCapital(
    country: 'Zambia',
    capital: 'Lusaka',
    latitude: -15.3875,
    longitude: 28.2833,
  ),
  CountryCapital(
    country: 'Zimbabwe',
    capital: 'Harare',
    latitude: -17.8252,
    longitude: 31.0335,
  ),
];

/// Finds a country by name (case-insensitive)
CountryCapital? findCountryCapital(String countryName) {
  try {
    return countryCapitals.firstWhere(
      (cc) => cc.country.toLowerCase() == countryName.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
}

/// Calculates the distance between two coordinates using the Haversine formula (in km)
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadiusKm = 6371.0;

  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);

  final double a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

double _degreesToRadians(double degrees) {
  return degrees * (3.141592653589793 / 180);
}

double sin(double x) => _sin(x);
double cos(double x) => _cos(x);
double sqrt(double x) => _sqrt(x);
double atan2(double y, double x) => _atan2(y, x);

// Math helper functions
double _sin(double x) {
  // Approximate sine using Taylor series
  x = x % (2 * 3.141592653589793);
  double result = 0;
  double term = x;
  for (int i = 1; i < 20; i++) {
    result += term;
    term *= -x * x / ((2 * i) * (2 * i + 1));
  }
  return result;
}

double _cos(double x) {
  // Approximate cosine using Taylor series
  x = x % (2 * 3.141592653589793);
  double result = 1;
  double term = 1;
  for (int i = 1; i < 20; i++) {
    term *= -x * x / ((2 * i - 1) * (2 * i));
    result += term;
  }
  return result;
}

double _sqrt(double x) {
  if (x < 0) return 0;
  if (x == 0) return 0;
  double prev = 0;
  double next = x;
  while ((next - prev).abs() > 1e-10) {
    prev = next;
    next = (next + x / next) / 2;
  }
  return next;
}

double _atan2(double y, double x) {
  if (x > 0) {
    return _atan(y / x);
  } else if (x < 0 && y >= 0) {
    return _atan(y / x) + 3.141592653589793;
  } else if (x < 0 && y < 0) {
    return _atan(y / x) - 3.141592653589793;
  } else if (x == 0 && y > 0) {
    return 3.141592653589793 / 2;
  } else if (x == 0 && y < 0) {
    return -3.141592653589793 / 2;
  }
  return 0;
}

double _atan(double x) {
  double result = 0;
  double term = x;
  double x2 = x * x;
  for (int i = 1; i < 20; i++) {
    result += term;
    term *= -x2 * (2 * i - 1) / (2 * i + 1);
  }
  return result;
}
