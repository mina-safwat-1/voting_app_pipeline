import psycopg2
import socket
import time
from datetime import datetime

def test_postgresql_connection(host, port, dbname, user, password, timeout=5):
    """
    Test connectivity to a PostgreSQL RDS instance
    
    Args:
        host (str): RDS endpoint
        port (int): Database port (default 5432 for PostgreSQL)
        dbname (str): Database name
        user (str): Database username
        password (str): Database password
        timeout (int): Connection timeout in seconds
        
    Returns:
        dict: Connection test results
    """
    results = {
        'timestamp': datetime.now().isoformat(),
        'host': host,
        'port': port,
        'success': False,
        'error': None,
        'latency_ms': None,
        'basic_connectivity': None,
        'database_connectivity': None
    }

    # Test basic network connectivity first
    try:
        start_time = time.time()
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        sock.connect((host, port))
        sock.close()
        results['basic_connectivity'] = True
        results['latency_ms'] = round((time.time() - start_time) * 1000, 2)
    except Exception as e:
        results['basic_connectivity'] = False
        results['error'] = f"Network connectivity failed: {str(e)}"
        return results

    # Test database connectivity
    conn = None
    try:
        start_time = time.time()
        conn = psycopg2.connect(
            host=host,
            port=port,
            dbname=dbname,
            user=user,
            password=password,
            connect_timeout=timeout
        )
        
        # Execute a simple query to verify working connection
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        if cursor.fetchone()[0] == 1:
            results['database_connectivity'] = True
            results['success'] = True
        cursor.close()
        
        results['latency_ms'] = round((time.time() - start_time) * 1000, 2)
        
    except Exception as e:
        results['database_connectivity'] = False
        results['error'] = f"Database connection failed: {str(e)}"
    finally:
        if conn:
            conn.close()
    
    return results

if __name__ == "__main__":
    # Configuration - replace with your RDS details
    RDS_CONFIG = {
        'host': 'database-1.ci98ky4msfdc.us-east-1.rds.amazonaws.com',
        'port': 5432,
        'dbname': 'postgres',
        'user': 'postgres',
        'password': 'postgres',
        'timeout': 5
    }
    
    print("Testing RDS PostgreSQL connectivity...")
    result = test_postgresql_connection(**RDS_CONFIG)
    
    print("\nTest Results:")
    print(f"Timestamp: {result['timestamp']}")
    print(f"Host: {result['host']}:{result['port']}")
    print(f"Basic Network Connectivity: {'✅ Success' if result['basic_connectivity'] else '❌ Failed'}")
    print(f"Database Connectivity: {'✅ Success' if result['database_connectivity'] else '❌ Failed'}")
    
    if result['latency_ms']:
        print(f"Latency: {result['latency_ms']} ms")
    
    if result['error']:
        print(f"Error: {result['error']}")
    
    print(f"\nOverall Status: {'✅ Connection successful' if result['success'] else '❌ Connection failed'}")

