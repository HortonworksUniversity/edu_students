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
	CREATE USER scm WITH PASSWORD 'BadPass%1';
	CREATE DATABASE scm WITH OWNER scm ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE scm TO scm;

	CREATE USER rman WITH PASSWORD 'BadPass%1';
	CREATE DATABASE rman WITH OWNER rman ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE rman TO rman;

	CREATE USER hue WITH PASSWORD 'BadPass%1';
	CREATE DATABASE hue WITH OWNER hue ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE hue TO hue;

	CREATE USER hive WITH PASSWORD 'BadPass%1';
	CREATE DATABASE metastore WITH OWNER hive ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;

	CREATE USER oozie WITH PASSWORD 'BadPass%1';
	CREATE DATABASE oozie WITH OWNER oozie ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE oozie TO oozie;

	CREATE USER rangeradmin WITH PASSWORD 'BadPass%1';
	CREATE DATABASE ranger WITH OWNER rangeradmin ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE ranger TO rangeradmin;

	CREATE USER schemaregistry WITH PASSWORD 'BadPass%1';
	CREATE DATABASE schemaregistry WITH OWNER schemaregistry ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE schemaregistry TO schemaregistry;

	CREATE USER smm WITH PASSWORD 'BadPass%1';
	CREATE DATABASE smm WITH OWNER smm ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE smm TO smm;

	CREATE USER devuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE cloudfin WITH OWNER devuser ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF8' LC_CTYPE = 'en_US.UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE cloudfin TO devuser;

EOSQL
}

# MAIN
createDB
