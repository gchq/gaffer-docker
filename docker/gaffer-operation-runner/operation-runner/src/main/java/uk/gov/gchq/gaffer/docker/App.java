/*
 * Copyright 2020 Crown Copyright
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package uk.gov.gchq.gaffer.docker;

import uk.gov.gchq.gaffer.graph.Graph;
import uk.gov.gchq.gaffer.graph.GraphConfig;
import uk.gov.gchq.gaffer.jsonserialisation.JSONSerialiser;
import uk.gov.gchq.gaffer.operation.Operation;
import uk.gov.gchq.gaffer.operation.OperationChain;
import uk.gov.gchq.gaffer.user.User;

import java.io.FileInputStream;
import java.nio.file.Paths;

public class App {
    public static void main(String[] args) {

        if (args.length != 4) {
            System.err.println("Wrong number of arguments provided. Expected 4 got " + args.length);
            return;
        }

        final String operationJson = args[0];
        final String schemaPath = args[1];
        final String storePropertiesPath = args[2];
        final String graphId = args[3];

        final Graph graph = new Graph.Builder().storeProperties(storePropertiesPath).addSchemas(Paths.get(schemaPath))
                .config(new GraphConfig.Builder().graphId(graphId).build()).build();

        final OperationChain operation = createOperationChain(operationJson);
        final Object result;
        try {
            result = graph.execute(operation, new User());
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        printResult(result);
    }

    private static void printResult(final Object result) {
        if (result instanceof Iterable) {
            System.out.println("Results:");
            for (Object value : (Iterable) result) {
                System.out.println(value);
            }
        } else {
            System.out.println("Result:");
            System.out.println(result);
        }
    }

    private static OperationChain createOperationChain(final String operationPath) {
        Operation op;
        try {
            op = JSONSerialiser.deserialise(new FileInputStream(operationPath), Operation.class);
        } catch (Exception e) {
            throw new RuntimeException("Could not deserialise object", e);
        }

        return op instanceof OperationChain ? (OperationChain) op : OperationChain.wrap(op);
    }

}
