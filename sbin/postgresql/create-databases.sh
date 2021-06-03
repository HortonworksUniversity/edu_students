#!/bin/bash

# Cloudera University
# This script is for training purposes only and is to be used only
# in support of approved Cloudera University exercises. Cloudera
# assumes no liability for use outside of our traning environments.
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Name: create-databases.sh
# Author: WKD
# Date: 170824
# Purpose: This is a build script to create users and databases for
# Cloudera Manager, Hue, Hive, Ranger, Ranger KMS, and Registery

# DEBUG
# set -x

# VARIABLE
USERNAME=postgres
DBNAME=postgres

# FUNCTIONS
function createDB() {
	psql -v ON_ERROR_STOP=1 --username "${USERNAME}" --dbname "${DBNAME}" <<-EOSQL
	CREATE USER cmserveruser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE cmserver WITH OWNER cmserveruser ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE cmserver TO cmserveruser;

	CREATE USER rmanuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE rman WITH OWNER rmanuser ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE rman TO rmanuser;

	CREATE USER hiveuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE metastore WITH OWNER hiveuser ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE metastore TO hiveuser;

	CREATE USER hueuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE hue WITH OWNER hueuser ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE hue TO hueuser;

	CREATE USER rangeradmin WITH PASSWORD 'BadPass%1';
	CREATE DATABASE ranger WITH OWNER rangeradmin ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE ranger TO rangeradmin;

	CREATE USER rangerkmsuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE rangerkms WITH OWNER rangerkmsuser ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE rangerkms TO rangerkmsuser;

	CREATE USER registry WITH PASSWORD 'BadPass%1';
	CREATE DATABASE registry WITH OWNER registry ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE registry TO registry;

	CREATE USER devuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE cloudfin WITH OWNER devuser ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF8' LC_CTYPE = 'en_US.UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE cloudfin TO devuser;

	CREATE DATABASE cloudtel WITH OWNER devuser ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF8' LC_CTYPE = 'en_US.UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE cloudtel TO devuser;

EOSQL
}

# MAIN
createDB
