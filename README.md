# chef-owncloud-cookbook

 Chef cookbook - installation and configuration cookbook for ownCloud

## Supported Platforms

 Debian

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['root_mysql_password']</tt></td>
    <td>String</td>
    <td>allows to (re-)init the root password</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['database_name']</tt></td>
    <td>String</td>
    <td>the name of the MySQL database</td>
    <td><tt>owncloud</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['database_password']</tt></td>
    <td>String</td>
    <td>the password of the ownCloud MySQL database</td>
    <td><tt>secret</tt></td>
  </tr>
</table>

## Usage

### chef-owncloud::default

Include `chef-owncloud` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef-owncloud::default]"
  ]
}
```

## License and Authors

Author:: PE, pf. (<peychart@mail.pf>)
