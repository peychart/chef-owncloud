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
    <td><tt>['chef-owncloud']['datadirectory']</tt></td>
    <td>String</td>
    <td>the data directory</td>
    <td><tt>'/var/www/owncloud/data'</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['ssl']['enable']</tt></td>
    <td>Boolean</td>
    <td>To enable ssl</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['ssl']['force']</tt></td>
    <td>Boolean</td>
    <td>force the use of ssl</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['otheroptions']</tt></td>
    <td>Array String</td>
    <td>Other configuration options</td>
    <td><tt>["'enable_avatars' => true","'appstoreenabled' => false","'blacklisted_files' => array('.htaccess')"]</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['dbhost']</tt></td>
    <td>String</td>
    <td>host hosting the database</td>
    <td><tt>127.0.0.1</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['dbtype']</tt></td>
    <td>String</td>
    <td>type of the database ('mysql' is the only currently possible)</td>
    <td><tt>mysql</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['dbrootpassword']</tt></td>
    <td>String</td>
    <td>allows to (re-)init the root password</td>
    <td><tt>secret</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['dbname']</tt></td>
    <td>String</td>
    <td>name of the owncloud database</td>
    <td><tt>owncloud</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['dbuser']</tt></td>
    <td>String</td>
    <td>Admin of the owncloud database (['dbname'] if nil)</td>
    <td><tt>''</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-owncloud']['dbpassword']</tt></td>
    <td>String</td>
    <td>the password of the ownCloud database</td>
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
