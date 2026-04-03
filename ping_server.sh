echo "Sending success traffic..."

for i in {1..21}; do
    curl -s http://localhost:8080/checkout > /dev/null
    sleep 0.2
done

echo "Injecting failure..."

curl -s http://localhost:8080/toggle-failure
sleep 0.5

echo "Sending failure traffic..."

for i in {1..11}; do
    curl -s http://localhost:8080/checkout > /dev/null
    sleep 0.2
done

echo "Done — check alerts"