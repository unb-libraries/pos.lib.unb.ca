<?php

require 'vendor/autoload.php';
require '../../application/config/database.php';

use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

if(!empty($_POST['startdate'])) {
  $filename = $_POST['startdate'] . '-to-' . $_POST['enddate'] . '.xlsx';
  header("Content-Type: application/vnd.ms-excel");
  header("Content-Disposition: attachment; filename=\"$filename\"");

  $db = new mysqli($db['default']['hostname'], $db['default']['username'], $db['default']['password'], $db['default']['database']);

  $sql = "SELECT
            CASE
              WHEN LOWER(i.name) LIKE '%taxed%' THEN CONCAT(i.category, ' (taxed)')
              ELSE i.category
              END AS item_name,
            CASE
              WHEN sp.payment_type IN('Cash', 'Check') THEN 'Cash / Check'
              WHEN sp.payment_type IN('Debit Card', 'Visa', 'Mastercard', 'American Express') THEN 'Debit / Credit'
              ELSE 'Other'
              END AS payment_category,
            ROUND(SUM(si.item_unit_price * si.quantity_purchased), 2) AS total
          FROM ospos_sales_items si
          JOIN ospos_sales s ON si.sale_id = s.sale_id
          JOIN ospos_sales_payments sp ON si.sale_id = sp.sale_id
          JOIN ospos_items i ON si.item_id = i.item_id
          WHERE s.sale_status = 0 AND s.sale_time >= ? AND s.sale_time <= ?
          GROUP BY item_name, payment_category
          ORDER BY payment_category, item_name";

  $stmt = $db->prepare($sql);
  $start = $_POST['startdate'] . ' 00:00:00';
  $end = $_POST['enddate'] . ' 23:59:59';
  $stmt->bind_param('ss', $start, $end);
  $stmt->execute();
  $res = $stmt->get_result();

  $cells = [
    'Cash / Check' => [
      'Bindery (taxed)' => 'F4',
      'Book Sales' => 'F6',
      'CDS (taxed)' => 'F8',
      'DDU (taxed)' => 'F10',
      'Fines' => 'F12',
      'Miscellaneous' => 'F14',
      'Miscellaneous (taxed)' => 'F15',
      'Paid Out' => 'F18',
      'Services' => 'F20',
      'Services (taxed)' => 'F21',
    ],
    'Debit / Credit' => [
      'Bindery (taxed)' => 'F36',
      'Book Sales' => 'F38',
      'CDS (taxed)' => 'F40',
      'DDU (taxed)' => 'F42',
      'Fines' => 'F44',
      'Miscellaneous' => 'F46',
      'Miscellaneous (taxed)' => 'F47',
      'Services' => 'F50',
      'Services (taxed)' => 'F51',
    ],
  ];

  $spreadsheet = IOFactory::load('/reporting/pos-template.xlsx');
  $spreadsheet->setActiveSheetIndex(0);
  $spreadsheet->getActiveSheet()->setCellValue('G1', date('Y-m-d'));
  while($row = $res->fetch_assoc()) {
    if(!empty($cells[$row['payment_category']][$row['item_name']])) {
      $spreadsheet->getActiveSheet()->setCellValue($cells[$row['payment_category']][$row['item_name']], $row['total']);
    }
  }

  $writer = new Xlsx($spreadsheet);
  $writer->save('php://output');
  exit;
}

?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tempusdominus-bootstrap-4/5.0.0-alpha14/css/tempusdominus-bootstrap-4.min.css" />
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
    <title>OSPOS Reporting</title>
  </head>
  <body>
    <div class="container">
      <h1>OSPOS Reporting</h1>
      <form method="POST">
      <div class='col-md-5'>
        <div class="form-group">
          <label for="startdate">Start Date</label>
          <div class="input-group date" id="startdate" data-target-input="nearest">
            <input type="text" class="form-control datetimepicker-input" name="startdate" data-target="#startdate" required />
            <div class="input-group-append" data-target="#startdate" data-toggle="datetimepicker">
              <div class="input-group-text"><i class="fa fa-calendar"></i></div>
            </div>
          </div>
        </div>
      </div>
      <div class='col-md-5'>
        <div class="form-group">
          <label for="enddate">End Date</label>
          <div class="input-group date" id="enddate" data-target-input="nearest">
            <input type="text" class="form-control datetimepicker-input" name="enddate" data-target="#enddate" required />
            <div class="input-group-append" data-target="#enddate" data-toggle="datetimepicker">
              <div class="input-group-text"><i class="fa fa-calendar"></i></div>
            </div>
          </div>
        </div>
      </div>
      <div class='col-md-5'>
        <button type="submit" class="btn btn-primary">Generate</button>
      </div>
      </form>
    </div>
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js" integrity="sha256-4iQZ6BVL4qNKlQ27TExEhBN1HFPvAvAMbFavKKosSWQ=" crossorigin="anonymous"></script>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/tempusdominus-bootstrap-4/5.0.0-alpha14/js/tempusdominus-bootstrap-4.min.js"></script>
    <script type="text/javascript">
      $(function () {
        $('#startdate').datetimepicker({
            format: 'Y-MM-DD'
        });
        $('#enddate').datetimepicker({
            useCurrent: false,
            format: 'Y-MM-DD'
        });
        $("#startdate").on("change.datetimepicker", function (e) {
            $('#enddate').datetimepicker('minDate', e.date);
        });
        $("#enddate").on("change.datetimepicker", function (e) {
            $('#startdate').datetimepicker('maxDate', e.date);
        });
      });
    </script>
  </body>
</html>
