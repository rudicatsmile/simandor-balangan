<?php
define('host', 'localhost');
define('name', 'root');
define('pass', '');
define('dbase', 'simbada_barsel_data_2025');

$conn = mysqli_connect(host, name, pass, dbase, 3306) or die('Unable to connect');
