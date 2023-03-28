/*
 * Copyright 2017-2023 Crown Copyright
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

package uk.gov.gchq.gaffer.federatedstore;

import uk.gov.gchq.gaffer.commonutil.StreamUtil;
import uk.gov.gchq.gaffer.federatedstore.operation.AddGraph;
import uk.gov.gchq.gaffer.federatedstore.operation.FederatedOperation;
import uk.gov.gchq.gaffer.federatedstore.operation.RemoveGraph;
import uk.gov.gchq.gaffer.operation.Operation;
import uk.gov.gchq.gaffer.operation.OperationException;
import uk.gov.gchq.gaffer.proxystore.ProxyProperties;
import uk.gov.gchq.gaffer.store.Context;
import uk.gov.gchq.gaffer.store.StoreException;
import uk.gov.gchq.gaffer.store.StoreProperties;
import uk.gov.gchq.gaffer.store.schema.Schema;
import uk.gov.gchq.gaffer.user.User;

import java.util.Collections;

import static uk.gov.gchq.gaffer.federatedstore.FederatedStoreTestUtil.GRAPH_ID_ACCUMULO_WITH_EDGES;
import static uk.gov.gchq.gaffer.federatedstore.FederatedStoreTestUtil.GRAPH_ID_ACCUMULO_WITH_ENTITIES;
import static uk.gov.gchq.gaffer.federatedstore.FederatedStoreTestUtil.resetForFederatedTests;
import static uk.gov.gchq.gaffer.user.User.UNKNOWN_USER_ID;

public class PublicAccessPredefinedFederatedStore extends FederatedStore {

    @Override
    public void initialise(final String graphId, final Schema schema, final StoreProperties properties)
            throws StoreException {
        resetForFederatedTests();

        super.initialise(graphId, schema, properties);

        // Used to set which container to proxy to
        final ProxyProperties proxyProperties = ProxyProperties.loadStoreProperties(StreamUtil.openStream(PublicAccessPredefinedFederatedStore.class, "proxyStore.properties"));

        // Add a Proxy to the FederatedStore rest container
        try {
            execute(new AddGraph.Builder()
                    .graphId("ProxyToFederatedStore")
                    .storeProperties(proxyProperties)
                    .isPublic(true)
                    .schema(new Schema())
                    .build(), new Context());
        } catch (final Exception e) {
            throw new StoreException("Error Adding Proxy Graph for IT tests", e);
        }

        // Remove Graphs from previous test runs
        try {
            final RemoveGraph removeEdgesGraph = new RemoveGraph.Builder()
                    .graphId(GRAPH_ID_ACCUMULO_WITH_EDGES)
                    .build();
            executeFederatedOperation(removeEdgesGraph);
        } catch (Exception e) {
            throw new StoreException("Error Removing Edges Graph for IT tests", e);
        }
        try {
            final RemoveGraph removeEntitiesGraph = new RemoveGraph.Builder()
                    .graphId(GRAPH_ID_ACCUMULO_WITH_ENTITIES)
                    .build();
            executeFederatedOperation(removeEntitiesGraph);
        } catch (Exception e) {
            throw new StoreException("Error Removing Entities Graph for IT tests", e);
        }

        // Add each Accumulo subgraph on the FederatedStore rest container
        try {
            final AddGraph addEdgesGraph = new AddGraph.Builder()
                    .graphId(GRAPH_ID_ACCUMULO_WITH_EDGES)
                    .storeProperties(FederatedStoreTestUtil
                            .loadAccumuloStoreProperties(FederatedStoreTestUtil.ACCUMULO_STORE_SINGLE_USE_PROPERTIES))
                    .schema(new Schema.Builder()
                            .merge(schema.clone())
                            // delete entities
                            .entities(Collections.emptyMap())
                            .build())
                    .parentSchemaIds(null)
                    .parentPropertiesId(null)
                    .isPublic(true)
                    .build();
            executeFederatedOperation(addEdgesGraph);
        } catch (Exception e) {
            throw new StoreException("Error Adding Edges Graph for IT tests", e);
        }

        try {
            final AddGraph addEntitiesGraph = new AddGraph.Builder()
                    .graphId(GRAPH_ID_ACCUMULO_WITH_ENTITIES)
                    .storeProperties(FederatedStoreTestUtil
                            .loadAccumuloStoreProperties(FederatedStoreTestUtil.ACCUMULO_STORE_SINGLE_USE_PROPERTIES))
                    .schema(new Schema.Builder()
                            .merge(schema.clone())
                            // delete edges
                            .edges(Collections.emptyMap())
                            .build())
                    .parentSchemaIds(null)
                    .parentPropertiesId(null)
                    .isPublic(true)
                    .build();
            executeFederatedOperation(addEntitiesGraph);
        } catch (Exception e) {
            throw new StoreException("Error Adding Entities Graph for IT tests", e);
        }
    }

    private Object executeFederatedOperation(final Operation addGraph) throws OperationException {
        return this.execute(
                new FederatedOperation.Builder()
                        .op(addGraph)
                        .build(),
                new Context(new User(UNKNOWN_USER_ID)));
    }
}
